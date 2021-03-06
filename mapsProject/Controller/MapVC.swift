//
//  ViewController.swift
//  mapsProject
//
//  Created by West Kraemer on 10/25/18.
//  Copyright © 2018 West Kraemer. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Alamofire
import AlamofireImage


class MapVC: UIViewController, UIGestureRecognizerDelegate {

    //mapview
    @IBOutlet weak var mapView: MKMapView!
  
    //constraint outlets
    @IBOutlet weak var pullUpViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var pullUpView: UIView!
    
    //variables for managing user location
    var locationManager = CLLocationManager()
    let authorizationStatus = CLLocationManager.authorizationStatus()
    let regionRadius: Double = 1000
    
    var screenSize = UIScreen.main.bounds
    
    var spinner: UIActivityIndicatorView?
    var progressLbl: UILabel?
    
    var flowLayout = UICollectionViewFlowLayout()
    var collectionView: UICollectionView?
    
    var imageUrlArray = [String]()
    var imageArray = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        configureLocationServices()
        addDoubleTap()
        
        //creating collection view
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        collectionView?.register(PhotoCell.self, forCellWithReuseIdentifier: "photoCell")
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        
        registerForPreviewing(with: self, sourceView: collectionView!)
        
        
        pullUpView.addSubview(collectionView!)
    }
    
    //allows user to drop a pin with double tap
    func addDoubleTap() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin(sender:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        mapView.addGestureRecognizer(doubleTap)
    }
    
    //lets a user swipe down to get rid of view that pops up
    func addSwipe() {
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(animateViewDown))
        swipe.direction = .down
        pullUpView.addGestureRecognizer(swipe)
    }
    
    //raises the view when the user drops a pin
    func animateViewUp() {
        pullUpViewHeightConstraint.constant = 300
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    //sends the view down when user swipes down on the view
    @objc func animateViewDown() {
        cancelAllSessions()
        pullUpViewHeightConstraint.constant = 0
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
   
    //adds the spinner to show the user that the app is loading images
    func addSpinner() {
        spinner = UIActivityIndicatorView()
        spinner?.center = CGPoint(x: (screenSize.width / 2) - ((spinner?.frame.width)! / 2), y: 150)
        spinner?.style = .whiteLarge
        spinner?.color = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        spinner?.startAnimating()
        collectionView?.addSubview(spinner!)
    }
    
    func removeSpinner() {
        if spinner != nil {
            spinner?.removeFromSuperview()
        }
    }
    
    func addProgressLbl() {
        progressLbl = UILabel()
        progressLbl?.frame = CGRect(x: (screenSize.width / 2) - 120, y: 175, width: 240, height: 40)
        progressLbl?.font = UIFont(name: "Avenir Next", size: 18)
        progressLbl?.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        progressLbl?.textAlignment = .center
        print("Your progress label is working")
//        progressLbl?.text = "12/40 Photos Loaded"
        collectionView?.addSubview(progressLbl!)
    }
    
    func removeProgressLbl() {
    if progressLbl != nil {
        progressLbl?.removeFromSuperview()
        }
    }
    
    //when the user has authorized it, centers map on location of the user
    @IBAction func centerMapBtnWasPressed(_ sender: Any) {
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
            centerMapOnUserLocation()
        }
    }
    
}


    extension MapVC: MKMapViewDelegate {
        
        //setting up the pin
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation {
                return nil
            }
            
            var pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
            pinAnnotation.pinTintColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
            pinAnnotation.animatesDrop = true
            return pinAnnotation
        }
        
        func centerMapOnUserLocation() {
            guard let coordinate = locationManager.location?.coordinate else {return}
            let coordinateRegion = MKCoordinateRegion.init(center: coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
            mapView.setRegion(coordinateRegion, animated: true)
        }
        
        //when a pin is dropped, do the following actions...
        @objc func dropPin(sender: UITapGestureRecognizer) {
            removePin()
            removeSpinner()
            removeProgressLbl()
            cancelAllSessions()
            
            imageUrlArray = []
            imageArray = []
            
            collectionView?.reloadData()
            
            animateViewUp()
            addSwipe()
            addSpinner()
            addProgressLbl()
            
            let touchPoint = sender.location(in: mapView)
            let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            let annotation = DroppablePin(coordinate: touchCoordinate, identifier: "droppablePin")
            mapView.addAnnotation(annotation)
            
            print(flickrUrl(forApiKey: apiKey, withAnnotation: annotation, andNumberOfPhotos: 40))

            let coordinateRegion = MKCoordinateRegion.init(center: touchCoordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
            mapView.setRegion(coordinateRegion, animated: true)
            
            retreiveUrls(forAnnotation: annotation) { (finished) in
                if finished {
                    self.retrieveImages(handler: { (finished) in
                        if finished {
                            self.removeSpinner()
                            self.removeProgressLbl()
                            self.collectionView?.reloadData()
                }
            })
        }
    }
}
        
        func removePin() {
            for annotation in mapView.annotations {
                mapView.removeAnnotation(annotation)
            }
        }
        
        //A function to get the url for images from alamofire. This will go through the json ////response with a for loop and return a response based on the infomration we send it //with our annotation coordinates.
        func retreiveUrls(forAnnotation annotation: DroppablePin, handler: @escaping (_ status: Bool) -> ()) {
            Alamofire.request(flickrUrl(forApiKey: apiKey, withAnnotation: annotation, andNumberOfPhotos: 40)).responseJSON { (response) in
                guard let json = response.result.value  as? Dictionary<String, AnyObject> else { return }
                let photosDict = json["photos"] as! Dictionary<String, AnyObject>
                let photosDictArray = photosDict["photo"] as! [Dictionary<String, AnyObject>]
                for photo in photosDictArray {
                    let postUrl = "https://farm\(photo["farm"]!).staticflickr.com/\(photo["server"]!)/\(photo["id"]!)_\(photo["secret"]!)_h_d.jpg"
                    self.imageUrlArray.append(postUrl)
                }
                handler(true)
                }
            }
        

        func retrieveImages(handler: @escaping (_ status: Bool) -> ()) {
            for url in imageUrlArray {
                Alamofire.request(url).responseImage(completionHandler: { (response)  in
                    guard let image = response.result.value else {return}
                    self.imageArray.append(image)
                    self.progressLbl?.text = "\(self.imageArray.count)/40 Images Downloaded"
                    if self.imageArray.count == self.imageUrlArray.count {
                        handler(true)
                    }
            })
        }
        }
        
        func cancelAllSessions() {
            Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (URLSessionDataTask, uploadData, downloadData) in
                URLSessionDataTask.forEach( { $0.cancel() } )
                downloadData.forEach( { $0.cancel() } )
            }
        }
        
        
        
}


extension MapVC: CLLocationManagerDelegate {
        func configureLocationServices() {
            if authorizationStatus == .notDetermined {
                locationManager.requestAlwaysAuthorization()
            } else {
                return
        }
    }
        
        func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            centerMapOnUserLocation()
        }
}

extension MapVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // number of items in array
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? PhotoCell else { return UICollectionViewCell() }
        let imageFromIndex = imageArray[indexPath.row]
        let imageView = UIImageView(image: imageFromIndex)
        cell.addSubview(imageView)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let popVC = storyboard?.instantiateViewController(withIdentifier: "PopVC") as? PopVC else {return}
        popVC.initData(forImage: imageArray[indexPath.row])
        present(popVC, animated: true, completion: nil)
    }
}


extension MapVC: UIViewControllerPreviewingDelegate {
  
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = collectionView?.indexPathForItem(at: location), let cell = collectionView?.cellForItem(at: indexPath) else {return nil}
        
        guard let popVC = storyboard?.instantiateViewController(withIdentifier: "PopVC") as? PopVC else {return nil}
        
        popVC.initData(forImage: imageArray[indexPath.row])
        
        previewingContext.sourceRect = cell.contentView.frame
        return popVC
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
    
}






