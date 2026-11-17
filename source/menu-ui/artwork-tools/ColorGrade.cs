using System;
using System.Buffers.Binary;
using System.Collections.Generic;
using System.IO;
using System.IO.Compression;
using System.Linq;
using System.Text;

// Display-referred sRGB only. Every output pixel is a color transformation of
// the input pixel at the same coordinate; there is no spatial filtering.
static class ColorGrade
{
    static readonly double[] ReferenceDeepTone = { 0,.10,.20,.29,.335,.43,.56,.70,.83,.92,1 };
    static readonly double[] ReferenceLightTone = { 0,.102,.202,.303,.348,.445,.57,.71,.835,.92,1 };
    static uint U32(ReadOnlySpan<byte> bytes) => BinaryPrimitives.ReadUInt32BigEndian(bytes);
    static int Paeth(int a, int b, int c)
    {
        int p = a + b - c, pa = Math.Abs(p-a), pb = Math.Abs(p-b), pc = Math.Abs(p-c);
        return pa <= pb && pa <= pc ? a : pb <= pc ? b : c;
    }
    static double Smooth(double a, double b, double v)
    {
        double t = Math.Clamp((v-a)/(b-a), 0, 1); return t*t*(3-2*t);
    }
    static double Hue(double p, double q, double t)
    {
        t -= Math.Floor(t);
        if (t < 1d/6) return p + (q-p)*6*t;
        if (t < .5) return q;
        if (t < 2d/3) return p + (q-p)*(2d/3-t)*6;
        return p;
    }
    static double ReferenceTone(double value, bool light)
    {
        double[] mapped = light ? ReferenceLightTone : ReferenceDeepTone;
        double index=value*10; int lower=Math.Min(9,(int)index);
        return mapped[lower]+(mapped[lower+1]-mapped[lower])*(index-lower);
    }
    static void Grade(byte[] pixels, int channels, double saturation, double hueDegrees, double gamma, string profile)
    {
        for (int i = 0; i < pixels.Length; i += channels)
        {
            double r=pixels[i]/255d, g=pixels[i+1]/255d, b=pixels[i+2]/255d;
            double high=Math.Max(r,Math.Max(g,b)), low=Math.Min(r,Math.Min(g,b));
            double l=(high+low)/2, h=0, s=0;
            if (high > low)
            {
                double d=high-low;
                s=l>.5 ? d/(2-high-low) : d/(high+low);
                h=high==r ? (g-b)/d+(g<b ? 6 : 0) : high==g ? (b-r)/d+2 : (r-g)/d+4;
                h/=6;
            }
            if(profile=="ref-b"||profile=="ref-c")
            {
                bool light=profile=="ref-c";
                double metal=Smooth(.42,.62,s), bright=Smooth(.60,.78,l);
                double saturationScale=(light ? .48 : .44)+.20*metal;
                saturationScale+=(light ? .86-saturationScale : .84-saturationScale)*bright;
                saturationScale*=1-.65*Smooth(.82,.99,l);
                double shift=3*(1-metal);
                shift+=(1.75-shift)*bright;
                h=(h+shift/360d)%1;
                s*=saturationScale;
                l=ReferenceTone(l,light);
            }
            else
            {
                h=(h+hueDegrees/360d)%1;
                // Move the warm specular highlights toward neutral white while
                // retaining the golden midtones and untouched black/white endpoints.
                s*=saturation*(1-.88*Smooth(.68,.96,l));
                double toned=Math.Pow(l,1/gamma);
                double protectHighlights=Smooth(.72,.97,l);
                l=toned+(l-toned)*protectHighlights;
            }
            double q=l<.5 ? l*(1+s) : l+s-l*s, p=2*l-q;
            r=s==0 ? l : Hue(p,q,h+1d/3);
            g=s==0 ? l : Hue(p,q,h);
            b=s==0 ? l : Hue(p,q,h-1d/3);
            pixels[i]=(byte)Math.Clamp(Math.Round(r*255),0,255);
            pixels[i+1]=(byte)Math.Clamp(Math.Round(g*255),0,255);
            pixels[i+2]=(byte)Math.Clamp(Math.Round(b*255),0,255);
        }
    }
    static void Chunk(Stream target, string name, byte[] data)
    {
        byte[] type=Encoding.ASCII.GetBytes(name), size=new byte[4];
        BinaryPrimitives.WriteUInt32BigEndian(size,(uint)data.Length); target.Write(size); target.Write(type); target.Write(data);
        uint crc=0xffffffff;
        foreach(byte v in type.Concat(data))
        {
            crc^=v; for(int i=0;i<8;i++) crc=(crc&1)!=0 ? 0xedb88320^(crc>>1) : crc>>1;
        }
        BinaryPrimitives.WriteUInt32BigEndian(size,crc^0xffffffff); target.Write(size);
    }
    static void Main(string[] args)
    {
        if(args.Length!=5&&args.Length!=9) throw new ArgumentException("input.png output.png saturation|identity hueDegrees gamma [previewCropX previewCropY previewCropWidth previewCropHeight]");
        bool identity=args[2]=="identity";
        string profile=args[2].StartsWith("ref-",StringComparison.Ordinal) ? args[2] : null;
        double sat=identity||profile!=null ? 1 : double.Parse(args[2],System.Globalization.CultureInfo.InvariantCulture);
        double hue=double.Parse(args[3],System.Globalization.CultureInfo.InvariantCulture);
        double gamma=double.Parse(args[4],System.Globalization.CultureInfo.InvariantCulture);
        byte[] input=File.ReadAllBytes(args[0]), header=null;
        var compressed=new MemoryStream();
        for(int offset=8;offset<input.Length;)
        {
            int size=checked((int)U32(input.AsSpan(offset,4))); string type=Encoding.ASCII.GetString(input,offset+4,4);
            if(type=="IHDR") header=input.AsSpan(offset+8,size).ToArray();
            if(type=="IDAT") compressed.Write(input,offset+8,size);
            offset+=size+12;
        }
        if(header==null||header[8]!=8||(header[9]!=2&&header[9]!=6)||header[12]!=0) throw new NotSupportedException("Requires non-interlaced 8-bit RGB or RGBA PNG.");
        int width=checked((int)U32(header.AsSpan(0,4))),height=checked((int)U32(header.AsSpan(4,4))),channels=header[9]==2 ? 3 : 4,stride=width*channels;
        compressed.Position=0; var raw=new MemoryStream();
        using(var decoder=new ZLibStream(compressed,CompressionMode.Decompress)) decoder.CopyTo(raw);
        byte[] scan=raw.ToArray(),pixels=new byte[height*stride];
        if(scan.Length!=(stride+1)*height) throw new InvalidDataException("Unexpected PNG raster length.");
        for(int y=0;y<height;y++)
        {
            int filter=scan[y*(stride+1)], start=y*stride;
            for(int x=0;x<stride;x++)
            {
                int a=x>=channels ? pixels[start+x-channels] : 0,b=y>0 ? pixels[start+x-stride] : 0,c=y>0&&x>=channels ? pixels[start+x-stride-channels] : 0;
                int predictor=filter switch {0=>0,1=>a,2=>b,3=>(a+b)/2,4=>Paeth(a,b,c),_=>throw new InvalidDataException("Invalid PNG filter.")};
                pixels[start+x]=unchecked((byte)(scan[y*(stride+1)+x+1]+predictor));
            }
        }
        if(!identity) Grade(pixels,channels,sat,hue,gamma,profile);
        if(args.Length==9)
        {
            int x=int.Parse(args[5]),y=int.Parse(args[6]),cw=int.Parse(args[7]),ch=int.Parse(args[8]);
            if(x<0||y<0||cw<1||ch<1||x+cw>width||y+ch>height) throw new ArgumentException("Preview crop is outside the source.");
            byte[] crop=new byte[cw*ch*channels];
            for(int row=0;row<ch;row++) Buffer.BlockCopy(pixels,(y+row)*stride+x*channels,crop,row*cw*channels,cw*channels);
            pixels=crop; width=cw; height=ch; stride=width*channels;
            BinaryPrimitives.WriteUInt32BigEndian(header.AsSpan(0,4),(uint)width);
            BinaryPrimitives.WriteUInt32BigEndian(header.AsSpan(4,4),(uint)height);
        }
        var outputRaster=new MemoryStream();
        using(var encoder=new ZLibStream(outputRaster,CompressionLevel.Optimal,true))
            for(int y=0;y<height;y++) { encoder.WriteByte(0); encoder.Write(pixels,y*stride,stride); }
        using(var output=File.Create(args[1]))
        {
            output.Write(input,0,8); Chunk(output,"IHDR",header); Chunk(output,"sRGB",new byte[]{0});
            Chunk(output,"IDAT",outputRaster.ToArray()); Chunk(output,"IEND",Array.Empty<byte>());
        }
        Console.WriteLine($"{Path.GetFileName(args[1])}: {width}x{height}, {(profile ?? $"sRGB HSL saturation={sat}, hue={hue} degrees, gamma={gamma}")}; {(args.Length==9 ? "preview crop only; no resampling" : "no spatial processing")}.");
    }
}
