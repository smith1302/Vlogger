
import UIKit

class ErrorHandler {
    static func showAlert(var error:String?) {
        error = (error == nil) ? "Something went wrong!" : error
        MessageHandler.showMessage(error!)
    }
}
