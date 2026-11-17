# Original-pixel gold color grade

This .NET 8 tool changes each pixel's color independently. It does not redraw, resize, resample, sharpen, blur, or move image content. The unchanged original wallpapers are the inputs, and the separate `Gold` variants are the outputs.

From the `source/menu-ui` folder:

```sh
dotnet run --project artwork-tools/ColorGrade.csproj -- integrated-ui/Assets/ScomMainMenu.png integrated-ui/Assets/ScomMainMenuGold.png ref-b 0 1
dotnet run --project artwork-tools/ColorGrade.csproj -- integrated-ui/Assets/ScomLobby.png integrated-ui/Assets/ScomLobbyGold.png 0.72 4 0.90
```

Arguments are input PNG, output PNG, saturation multiplier or profile name, hue shift in degrees, and midtone gamma. The main-menu `ref-b` profile supplies a monotonic lightness curve and color-dependent saturation to match the preferred muted gold reference; the final two arguments are unused compatibility values for this profile. The lobby keeps its previous HSL grade. RGB/RGBA pixel positions, dimensions and alpha are preserved. Non-interlaced 8-bit RGB and RGBA PNG files are supported.

Passing `identity` instead of the saturation multiplier bypasses the color grade for an exact raster roundtrip check. The current wallpapers were checked against the originals pixel for pixel in this mode. The final color grades were also checked for position-independent mapping of every source color.
