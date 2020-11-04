
import Foundation

import UIKit

public class FrameworkUtil {

    public static func performSegueToFrameworkVC(caller: UIViewController) {
        let podBundle = Bundle(for: FrameworkUtil.self)

        let bundleURL = podBundle.url(forResource: "BirdEye", withExtension: "bundle")
        let bundle = Bundle(url: bundleURL!)!
        let storyboard = UIStoryboard(name: "BirdEye", bundle: bundle)
        let vc = storyboard.instantiateInitialViewController()!
        caller.present(vc, animated: true, completion: nil)
    }
    
    static var bundle:Bundle {
        let podBundle = Bundle(for: FrameworkUtil.self)

        let bundleURL = podBundle.url(forResource: "BirdEye", withExtension: "bundle")
        return Bundle(url: bundleURL!)!
    }
}

