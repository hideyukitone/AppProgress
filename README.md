# AppProgress
Appleらしいローディングができます。

<image src="https://user-images.githubusercontent.com/11258432/40573794-d5d4ffc2-6101-11e8-950c-db5545dea18a.gif" width="300">
  
## 使い方
App Extensionでも使えるようにするため、`UIApplication.shared.windows`から表示させるUIWindowを内部で取得せず、渡すようにしています。
下記のようなextensionを作ると良いかと思います。
```ruby
import UIKit
import AppProgress

extension AppProgress {
    static func show(string: String = "") {
        guard let window = window else { return }
        
        show(view: window, string: string)
    }
    
    static func done(string: String = "", completion: (() -> Void)? = nil) {
        guard let window = window else { return }
        
        done(view: window, string: string, completion: completion)
    }
    
    static func info(string: String = "", completion: (() -> Void)? = nil) {
        guard let window = window else { return }
        
        info(view: window, string: string, completion: completion)
    }
    
    static func err(string: String = "", completion: (() -> Void)? = nil) {
        guard let window = window else { return }
        
        err(view: window, string: string, completion: completion)
    }
    
    static func custom(image: UIImage?, imageRenderingMode: UIImageRenderingMode = .alwaysTemplate, string: String = "", isRotation: Bool = false, completion: (() -> Void)? = nil) {
        guard let window = window else { return }
        
        custom(view: window, image: image, imageRenderingMode: imageRenderingMode, string: string, isRotation: isRotation, completion: completion)
    }
    
    private static var window: UIWindow? {
        for window in UIApplication.shared.windows where !window.isHidden && window.alpha > 0 && window.screen == UIScreen.main && window.windowLevel == UIWindowLevelNormal {
            return window
        }
        
        return nil
    }
}
```

### show
![AppProgress](https://user-images.githubusercontent.com/11258432/40573454-dc2e3208-60fc-11e8-8e0f-87952a46c10c.gif)
```ruby
AppProgress.show(view: view)
```

### done
![done](https://user-images.githubusercontent.com/11258432/40573722-60877890-6100-11e8-97d4-694c51161b59.gif)
```ruby
AppProgress.done(view: view)
```

### err
![error](https://user-images.githubusercontent.com/11258432/40573723-60ab03c8-6100-11e8-998f-ec5a34aa9024.gif)
```ruby
AppProgress.err(view: view)
```

### info
![info](https://user-images.githubusercontent.com/11258432/40573724-60cdba6c-6100-11e8-9f1b-42f0dbd8cffc.gif)
```ruby
AppProgress.info(view: view)
```
