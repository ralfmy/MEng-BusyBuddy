//
//  SceneDelegate.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 01/11/2020.
//

import UIKit
import SwiftUI
import os.log

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    private let logger = Logger(subsystem: "com.zcabrmy.BusyBuddy", category: "SceneDelegate")

    var window: UIWindow?
    var timer: Timer?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).

        // Get the managed object context from the shared persistent container.
        let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
        let favouritesManager = (UIApplication.shared.delegate as! AppDelegate).favouritesManager
        let imageCache = (UIApplication.shared.delegate as! AppDelegate).cache
        
        let store = PlacesDataManager(persistentContainer: container, managedObjectContext: container.viewContext)
        
        
        // NEED TO CHECK WHEN LAST API FETCH OCCURRED
        if store.places.isEmpty {
            self.logger.info("INFO: No saved places. Fetching all places from TfL Unified API.")
            TfLUnifiedAPI().fetchAllJamCams() { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let places):
                        store.savePlaces(places: places)
                    case .failure(let err):
                        self.logger.error("ERROR: Failure to fetch: \(err as NSObject)")
                    }
                }
            }
        }
        
//        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { timer in
//            favourites.list().forEach { place in
//                var image: UIImage?
//                if let data = try? Data(contentsOf: URL(string: place.getImageUrl())!) {
//                    if let uiImage = UIImage(data: data) {
//                        image = uiImage
//                    }
//                }
//                if image != nil {
//                    imageCache.addImage(forKey: place.id, image: image!)
//                }
//            }
//        }
        
        // Create the SwiftUI view and set the context as the value for the managedObjectContext environment keyPath.
        // Add `@Environment(\.managedObjectContext)` in the views that will need the context.
        let placesView = PlacesView().environmentObject(store).environmentObject(favouritesManager).environmentObject(imageCache)

        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: placesView)
            self.window = window
            window.makeKeyAndVisible()
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
//        timer!.invalidate()
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }


}

