#!/usr/bin/env python3
"""Bake foreground-preserving depth of field into authored menu photos.

Input is the ref-b color-graded original. Requires Pillow. Ship coordinates use
its full frame; city coordinates use the original before removing letterboxing.
"""
import argparse
from array import array
from pathlib import Path
from PIL import Image, ImageChops, ImageDraw, ImageFilter, PngImagePlugin

SHIP = [
    (96, 676), (141, 628), (176, 611), (201, 581), (286, 575),
    (325, 549), (351, 543), (375, 537), (384, 509), (389, 476),
    (398, 469), (398, 431), (427, 440), (427, 458), (411, 461),
    (414, 481), (429, 482), (436, 514), (444, 542), (451, 539),
    (463, 530), (480, 519), (483, 535), (477, 543), (468, 551),
    (467, 575), (486, 573), (492, 596), (510, 606), (516, 572),
    (529, 568), (530, 534), (538, 529), (544, 533), (570, 540),
    (576, 538), (578, 541), (564, 547), (554, 564), (554, 575),
    (566, 575), (576, 569), (579, 572), (558, 582), (558, 635),
    (580, 638), (598, 642), (598, 630), (603, 628), (607, 632),
    (619, 623), (623, 619), (626, 620), (620, 630), (625, 650),
    (654, 651), (670, 648), (680, 653), (681, 664),
    (680, 648), (722, 650), (777, 665), (827, 643), (918, 608),
    (946, 597), (977, 610), (982, 640), (959, 666), (946, 684),
    (927, 704), (987, 739), (1046, 755), (1168, 713),
    (1200, 706), (1235, 724), (1258, 753), (1280, 810),
    (1191, 851), (1151, 860), (1136, 882), (1140, 911),
    (1129, 941), (327, 941), (278, 913), (242, 899), (214, 878),
    (205, 857), (176, 844), (162, 823), (143, 814), (132, 789),
    (118, 770), (123, 746), (104, 736), (97, 714),
]
CITY = [
    (768, 121), (831, 121), (830, 149), (916, 184), (990, 275),
    (1027, 283), (1035, 254), (1013, 239), (993, 219), (963, 196),
    (961, 192), (964, 190), (969, 192), (1004, 216), (980, 179),
    (975, 167), (974, 159), (975, 155), (978, 155), (1002, 180),
    (980, 144), (977, 139), (977, 137), (980, 136), (984, 137),
    (1033, 181), (1035, 189), (1057, 183), (1084, 182), (1092, 171),
    (1139, 174), (1154, 179), (1158, 167), (1161, 166), (1164, 171),
    (1185, 220), (1192, 240), (1185, 246), (1197, 265), (1178, 274),
    (1178, 300), (1169, 317), (1193, 310), (1243, 227), (1258, 216),
    (1290, 197), (1278, 160), (1277, 147), (1278, 145), (1265, 121),
    (1300, 121), (1318, 143), (1332, 164), (1344, 183),
    (1355, 202), (1366, 222), (1374, 235),
    (1394, 221), (1410, 277), (1433, 328), (1427, 359),
    (1445, 389), (1439, 420), (1421, 442), (1445, 468),
    (1441, 498), (1463, 533), (1451, 559), (1475, 584),
    (1446, 605), (1460, 635), (1612, 627), (1641, 641),
    (1650, 672), (1672, 681), (1672, 819), (731, 819),
    (731, 813), (725, 800), (704, 788), (692, 771), (682, 750),
    (676, 733), (671, 717), (670, 687), (659, 683), (641, 684),
    (634, 679), (629, 668), (627, 651), (631, 642), (642, 631),
    (653, 627), (665, 632), (656, 626), (642, 624), (635, 613),
    (635, 599), (641, 580), (649, 573), (658, 573), (663, 557),
    (669, 552), (686, 563), (692, 552), (685, 550), (677, 537),
    (679, 520), (686, 493), (697, 447), (696, 442), (684, 424),
    (682, 415), (684, 401), (679, 385), (675, 376), (672, 359),
    (669, 349), (655, 334), (671, 316), (687, 300), (700, 296),
    (630, 273), (611, 240), (618, 206),
    (632, 151), (666, 222), (794, 256), (842, 297), (850, 284),
    (858, 281), (820, 232), (749, 191), (746, 187),
]
CITY_GAPS = [
    [(789, 505), (813, 496), (826, 488), (838, 468), (850, 484),
     (910, 492), (938, 499), (957, 508), (936, 514), (944, 530),
     (951, 559), (978, 590), (979, 631), (917, 612), (914, 633),
     (876, 615), (865, 623), (850, 620), (847, 594), (840, 569),
     (833, 551), (808, 546), (798, 539), (790, 537)],
    [(802, 736), (829, 748), (858, 758), (892, 764), (895, 819),
     (760, 819), (776, 796), (787, 770), (789, 751)],
    [(720, 692), (734, 697), (719, 743), (716, 746)],
    [(872, 637), (885, 677), (857, 669)],
    [(883, 707), (880, 718), (875, 715)],
    [(1252, 555), (1276, 527), (1278, 517), (1284, 529),
     (1306, 541), (1315, 542), (1322, 538), (1339, 567),
     (1357, 600), (1376, 626), (1383, 638), (1371, 643),
     (1363, 657), (1334, 692), (1333, 593), (1325, 587),
     (1263, 594), (1252, 605)],
    [(1348, 726), (1361, 699), (1376, 718), (1398, 741),
     (1420, 765), (1441, 783), (1460, 795), (1465, 819),
     (1348, 819)],
    [(1407, 616), (1413, 623), (1419, 623), (1421, 626), (1411, 628)],
]
RADII = (0, .5, 1, 2, 3, 4.5)
FOCUS_FALLOFF = 24


def distance_from_subject(mask):
    """Two-pass chamfer distance gives thin details the same gentle falloff."""
    width, height = mask.size
    distance = array('f', (0 if v else width + height for v in mask.tobytes()))
    diagonal = 2 ** .5
    for y in range(height):
        for x in range(width):
            i = y * width + x
            best = distance[i]
            if x: best = min(best, distance[i - 1] + 1)
            if y:
                best = min(best, distance[i - width] + 1)
                if x: best = min(best, distance[i - width - 1] + diagonal)
                if x + 1 < width: best = min(best, distance[i - width + 1] + diagonal)
            distance[i] = best
    for y in range(height - 1, -1, -1):
        for x in range(width - 1, -1, -1):
            i = y * width + x
            best = distance[i]
            if x + 1 < width: best = min(best, distance[i + 1] + 1)
            if y + 1 < height:
                best = min(best, distance[i + width] + 1)
                if x: best = min(best, distance[i + width - 1] + diagonal)
                if x + 1 < width: best = min(best, distance[i + width + 1] + diagonal)
            distance[i] = best
    return distance


def background_blur(image, foreground, radius, divide):
    """Normalized background-only blur prevents bright subject-edge halos."""
    if radius == 0:
        return image
    weight = ImageChops.invert(foreground)
    weighted = Image.composite(Image.new('RGB', image.size), image, foreground)
    weights = weight.filter(ImageFilter.GaussianBlur(radius)).tobytes()
    blurred = weighted.filter(ImageFilter.GaussianBlur(radius))
    channels = []
    for channel in blurred.split():
        values = bytes(divide[(w << 8) | v] for w, v in zip(weights, channel.tobytes()))
        channels.append(Image.frombytes('L', image.size, values))
    return Image.merge('RGB', channels)


def ship_radius(y):
    # Distant sky/shore/ships are soft; nearby water falls back toward focus.
    stops = ((0, 4.5), (300, 4.5), (440, 3.5), (620, 1.8), (800, .5), (941, 0))
    for (a, ra), (b, rb) in zip(stops, stops[1:]):
        if y <= b:
            t = max(0, (y - a) / (b - a))
            return ra + (rb - ra) * t
    return 0


def repair_city_eye(image):
    """Restore the eye's smooth taper using its intact left cross-section."""
    if image.size != (1672, 698) or image.mode != 'RGB':
        raise ValueError('The eye retouch requires the authored cropped RGB city image.')
    # Cropped output coordinates. Transport the clean red profile along the
    # eye's diagonal and narrow it toward the existing tip. Feather horizontally
    # into intact pixels; never brighten the surrounding low-intensity glow.
    strengths = (.2, .4, .7, 1, 1, 1, 1, 1, .95, .85, .65, .4, .15)
    result = image.copy()
    for x, strength in zip(range(1114, 1127), strengths):
        offset = x - 1113
        top = 107 + .7 * offset
        bottom = 114 + .37 * offset
        for y in range(108, 120):
            sample_y = 107 + (y - top) * 7 / (bottom - top)
            lower = int(sample_y)
            fraction = sample_y - lower
            a = image.getpixel((1113, lower))
            b = image.getpixel((1113, lower + 1))
            fill = tuple(v + (w - v) * fraction for v, w in zip(a, b))
            original = image.getpixel((x, y))
            if fill[0] > max(140, original[0]):
                result.putpixel((x, y), tuple(round(a + (b - a) * strength)
                                             for a, b in zip(original, fill)))
    return result


def bake(scene, source, output):
    with Image.open(source) as original:
        if original.size != (1672, 941):
            raise ValueError('This authored focus mask requires the 1672 x 941 original.')
        if 'A' in original.getbands() and original.getchannel('A').getextrema() != (255, 255):
            raise ValueError('These menu photographs must be opaque.')
        image = original.convert('RGB')
    crop_top = 121 if scene == 'city' else 0
    if scene == 'city':
        image = image.crop((0, 121, 1672, 819))
    polygon = CITY if scene == 'city' else SHIP
    hard = Image.new('L', image.size)
    painter = ImageDraw.Draw(hard)
    painter.polygon([(x, y - crop_top) for x, y in polygon], fill=255)
    if scene == 'city':
        for gap in CITY_GAPS:
            painter.polygon([(x, y - crop_top) for x, y in gap], fill=0)
    else:
        painter.polygon([(531, 583), (540, 582), (540, 612), (531, 615)], fill=0)
        painter.polygon([(531, 624), (541, 622), (541, 632), (531, 634)], fill=0)
    # Protect the original antialiased silhouette and thin tips while allowing
    # the background focus falloff to start outside the authored subject.
    hard = hard.filter(ImageFilter.MaxFilter(7))
    divide = bytes(0 if w == 0 else min(255, (v * 255 + w // 2) // w)
                   for w in range(256) for v in range(256))
    layers = [background_blur(image, hard, r, divide) for r in RADII]
    width, height = image.size
    distance = distance_from_subject(hard)
    radii = bytearray(width * height)
    for y in range(height):
        plane_radius = 3.5 if scene == 'city' else ship_radius(y)
        for x in range(width):
            i = y * width + x
            t = min(1, distance[i] / FOCUS_FALLOFF)
            smooth = t * t * (3 - 2 * t)
            radii[i] = round(255 * plane_radius * smooth / RADII[-1])
    plans = []
    for value in range(256):
        radius = value * RADII[-1] / 255
        upper = next(i for i, r in enumerate(RADII) if r >= radius)
        lower = max(0, upper - 1)
        t = 0 if upper == lower else (radius - RADII[lower]) / (RADII[upper] - RADII[lower])
        plans.append((lower, upper, round(t * 255)))
    # Interpolate adjacent blur levels, not sharp pixels against a fully blurred
    # backdrop. This avoids a visible cutout or ghost-texture band at the subject.
    pixels = [layer.tobytes() for layer in layers]
    output_pixels = bytearray(width * height * 3)
    for i, value in enumerate(radii):
        lower, upper, t = plans[value]
        a, b = pixels[lower], pixels[upper]
        for channel in range(3):
            j = i * 3 + channel
            output_pixels[j] = (a[j] * (255 - t) + b[j] * t + 127) // 255
    result = Image.frombytes('RGB', image.size, bytes(output_pixels))
    a, b, mask = image.tobytes(), result.tobytes(), hard.tobytes()
    preserved = sum(v == 255 for v in mask)
    assert all(a[3*i:3*i+3] == b[3*i:3*i+3] for i, v in enumerate(mask) if v == 255)
    retouched = 0
    if scene == 'city':
        repaired = repair_city_eye(result)
        retouched = sum(a != b for a, b in zip(result.getdata(), repaired.getdata()))
        result = repaired
    metadata = PngImagePlugin.PngInfo()
    metadata.add(b'sRGB', b'\0')
    result.save(output, pnginfo=metadata, compress_level=6)
    print(f'{Path(output).name}: {width}x{height}; {preserved - retouched:,} foreground pixels kept exact; '
          f'{retouched} eye pixels retouched; background-only depth blur.')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('scene', choices=('ship', 'city'))
    parser.add_argument('source', type=Path)
    parser.add_argument('output', type=Path)
    args = parser.parse_args()
    bake(args.scene, args.source, args.output)
