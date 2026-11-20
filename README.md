# LiquidGlas - iOS Control Center Liquid Glass Effect

## ✨ Features

- 🌊 **Liquid Glass Effect** - Stunning glassmorphism on Control Center panel
- ⚙️ **Customizable Settings** - Adjust opacity, blur, gloss level, corner radius
- 🎨 **Color Tint Support** - Customize the glass color appearance
- 💎 **Smooth Animations** - Fluid transition effects

## 📥 Installation

### Method 1: Cydia Saurik Repository

apt-get install liquidglas

### Method 2: Direct Installation

1. Download .deb package from GitHub Releases
2. Install using Cydia Impactor or Sileo
3. Reboot your device after installation

## ⚙️ Configuration Settings

| Setting | Description | Default Range |
|---------|-------------|---------------|
| Enable Liquid Glass | Turn on/off the glass effect | ON / OFF |
| Glass Opacity | Control transparency level | 0 - 100% |
| Glass Blur | Background blur intensity | 0 - 50px |
| Gloss Level | Reflection/glossy finish | 0 - 100% |
| Corner Radius | Rounded corner size | 0 - 100px |
| Color Tint | Custom glass color | #2563eb (Blue) |

## 🔄 Troubleshooting

### Effect not appearing?

1. Ensure Control Center is enabled in Settings
2. Reboot your device after installation
3. Check if the tweak loaded correctly via Cydia → Packages

### Visual glitches?

1. Update to the latest version
2. Clear Cache: rm -rf /var/cache/com.lqtg.LiquidGlass
3. Uninstall and reinstall the tweak

## 📦 Build from Source

make package
find release-debs -name "*.deb"

## 🔧 Technical Details

- Architecture: arm64 (iOS 14+)
- Framework Dependencies: UIKit, QuartzCore, Substrate
- Process Injection: ControlCenterSpringBoard
- Dynamic Libraries: LiquidGlass27.dylib, BGRenderServer.dylib, BGWidgetRenderer.dylib

## ⚠️ License

This project is licensed under the GPL-3.0 License - see LICENSE file for details.

---

Made with ❤️ by LQTG