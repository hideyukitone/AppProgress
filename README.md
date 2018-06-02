# AppProgress
Appleらしいローディングができます。

<image src="https://user-images.githubusercontent.com/11258432/40573794-d5d4ffc2-6101-11e8-950c-db5545dea18a.gif" width="300">

## CocoaPods
```
use_frameworks!

pod 'AppProgress'
```

#### App Extension
App Extensionでも使えるようにするため、`UIApplication.shared.windows`から表示させるUIWindowを内部で取得せず、渡すようにしています。
```
use_frameworks!

pod 'AppProgressCore'
```

## 使い方
### show
![AppProgress](https://user-images.githubusercontent.com/11258432/40573454-dc2e3208-60fc-11e8-8e0f-87952a46c10c.gif)
```ruby
AppProgress.show()
```

### done
![done](https://user-images.githubusercontent.com/11258432/40573722-60877890-6100-11e8-97d4-694c51161b59.gif)
```ruby
AppProgress.done()
```

### err
![error](https://user-images.githubusercontent.com/11258432/40573723-60ab03c8-6100-11e8-998f-ec5a34aa9024.gif)
```ruby
AppProgress.err()
```

### info
![info](https://user-images.githubusercontent.com/11258432/40573724-60cdba6c-6100-11e8-9f1b-42f0dbd8cffc.gif)
```ruby
AppProgress.info()
```

## メソッド
```ruby
open static func set(colorType: ColorType)
open static func set(backgroundStyle: BackgroundStyle)
open static func set(minimumDismissTimeInterval: TimeInterval)

open static func show(string: String = "")
open static func done(string: String = "", completion: (() -> Void)? = nil)
open static func info(string: String = "", completion: (() -> Void)? = nil)
open static func err(string: String = "", completion: (() -> Void)? = nil)
open static func custom(image: UIImage?, imageRenderingMode: UIImageRenderingMode = .alwaysTemplate, string: String = "", isRotation: Bool = false, completion: (() -> Void)? = nil)

open static func dismiss(completion: (() -> Void)? = nil)
```

## License
MIT
