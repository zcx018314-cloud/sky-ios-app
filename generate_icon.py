from PIL import Image, ImageDraw
import os

img = Image.new('RGB', (1024, 1024), (91, 106, 191))
draw = ImageDraw.Draw(img)

for radius in range(512, 0, -8):
    color = (
        min(233, 91 + (512 - radius) // 4),
        min(69, 106),
        min(96, 191)
    )
    draw.ellipse([512 - radius, 512 - radius, 512 + radius, 512 + radius], outline=color, width=4)

draw.ellipse([312, 312, 712, 712], fill=(255, 255, 255))

draw.ellipse([402, 362, 622, 562], fill=(91, 106, 191))
draw.ellipse([402, 462, 622, 662], fill=(91, 106, 191))
draw.rectangle([402, 462, 622, 470], fill=(91, 106, 191))

path = r'C:\Users\Administrator\Desktop\sky-ios-app\SkyApp\Assets.xcassets\AppIcon.appiconset\AppIcon.png'
img.save(path)
print(f'Icon saved: {os.path.getsize(path)} bytes')