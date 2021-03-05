//
//  The.swift
//  All
//
//  Created by Joshua Laurence on 18/10/2020.
//

import UIKit

class TheCell: UICollectionViewCell {
    
    
    @IBOutlet weak var TheCellImageView: UIImageView!
    @IBOutlet weak var TheCellTitleLabel: UILabel!
    
    override var isSelected: Bool {
        didSet {
            
        }
    }
    
}

class The: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var TheCollectionView: UICollectionView!
    
    let apps = [[UIImage(systemName: "camera.on.rectangle.fill"), "PhotoText"]] as [[Any]]
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (apps.count)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TheCell", for: indexPath) as! TheCell
        cell.TheCellImageView.image = apps[indexPath.row][0] as! UIImage
        cell.TheCellTitleLabel.text = apps[indexPath.row][1] as! String
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let title = String(apps[indexPath.row][1] as! String + "Segue")
        self.performSegue(withIdentifier: title, sender: self)
    }
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        TheCollectionView.delegate = self
        TheCollectionView.dataSource = self
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 182, height: 182)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        
        TheCollectionView.collectionViewLayout = layout
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
