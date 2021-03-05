//
//  ViewController.swift
//  PhotoText
//
//  Created by Joshua Laurence on 07/10/2020.
//

import UIKit
import Foundation
import Vision
import VisionKit
import CoreData
import PDFKit

var Notes = [[String]]()

class ViewNotePage: UIViewController, UITextViewDelegate, UITextFieldDelegate {
    
    var global = GlobalFunctions()
    var noteIndex = Int()
    
    func setNotes() {
        Notes[noteIndex][0] = ViewNotePageTitle.text!
        Notes[noteIndex][1] = ViewNotePageContent.text
    }
    
    @IBOutlet weak var ViewNotePageTrash: UIButton!
    @IBAction func ViewNotePageTrashButton(_ sender: UIButton) {
        let al = UIAlertController(title: "Delete", message: "Are you sure you want to delete this note. This can't be reversed!", preferredStyle: .actionSheet)
        al.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        al.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
            Notes.remove(at: self.noteIndex)
            self.navigationController?.popToRootViewController(animated: true)
        }))
        self.present(al, animated: true, completion: nil)
    }
    
    @IBOutlet weak var ViewNotePagePin: UIButton!
    @IBAction func ViewNotePagePinButton(_ sender: UIButton) {
    }
    
    @IBOutlet weak var ViewNotePageShare: UIButton!
    @IBAction func ViewNotePageShareButton(_ sender: UIButton) {
        setNotes()
        let al = UIAlertController(title: "Exporting Options", message: "", preferredStyle: .actionSheet)
        al.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        al.addAction(UIAlertAction(title: "Copy To Clipboard", style: .default, handler: { (action) in
            UIPasteboard.general.strings = []
            UIPasteboard.general.string = Notes[self.noteIndex][1]
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }))
        al.addAction(UIAlertAction(title: "Share", style: .default, handler: { (action) in
            let activityController = UIActivityViewController(activityItems: [Notes[self.noteIndex][1]], applicationActivities: nil)
            DispatchQueue.main.async {
                self.present(activityController, animated: true, completion: nil)
            }
        }))
        self.present(al, animated: true, completion: nil)
    }
    
    @IBOutlet weak var ViewNotePageTitle: UITextField!
    @IBOutlet weak var ViewNotePageContent: UITextView!
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.ViewNotePageTitle.endEditing(true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.ViewNotePageTitle.endEditing(true)
        self.ViewNotePageContent.endEditing(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        setNotes()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ViewNotePageShare.layer.cornerRadius = 26
        ViewNotePagePin.layer.cornerRadius = 26
        
        ViewNotePageTitle.delegate = self
        ViewNotePageContent.delegate = self
        
        self.navigationController?.navigationBar.isHidden = true
        ViewNotePageTitle.text = Notes[noteIndex][0]
        ViewNotePageContent.text = Notes[noteIndex][1]
    }
    
}

class HomePageTVCell: UITableViewCell {
    
    @IBOutlet weak var HomePageTVCellTitle: UILabel!
    @IBOutlet weak var HomePageTVCellContent: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

class HomePage: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIImagePickerControllerDelegate, VNDocumentCameraViewControllerDelegate, UINavigationControllerDelegate, UIDocumentPickerDelegate {
    
    @IBAction func HomeButtonAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: Variable Declaration
    var global = GlobalFunctions()
    var ind = Int()
    var notesFiltered = [[String]]()
    
    // MARK: Edit Configuartion
    func editingOff() {
        HomePageTrash.isHidden = true
        HomePageTrash.isEnabled = false
        HomePageEdit.setImage(UIImage(systemName: "pencil"), for: .normal)
        HomePageInformationTableView.setEditing(false, animated: true)
    }
    
    @IBOutlet weak var HomePageEdit: UIButton!
    @IBAction func HomePageEditButton(_ sender: UIButton) {
        if HomePageEdit.imageView?.image == UIImage(systemName: "pencil") {
            HomePageTrash.isHidden = false
            HomePageEdit.setImage(UIImage(systemName: "checkmark"), for: .normal)
            HomePageInformationTableView.setEditing(true, animated: true)
        } else if HomePageEdit.imageView?.image == UIImage(systemName: "checkmark") {
            editingOff()
        }
    }
    
    // MARK: Trash Button Configuartion
    @IBOutlet weak var HomePageTrash: UIButton!
    @IBAction func HomePageTrashButton(_ sender: UIButton) {
        let message = "Are you sure you want to delete \(HomePageInformationTableView.indexPathsForSelectedRows!.count) items. This action is not reversable!"
        let title = "Delete \(HomePageInformationTableView.indexPathsForSelectedRows!.count)"
        let al = UIAlertController(title: "Delete", message: message, preferredStyle: .actionSheet)
        al.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        al.addAction(UIAlertAction(title: title, style: .destructive, handler: { (action) in
            for a in self.HomePageInformationTableView.indexPathsForSelectedRows! {
                if a.row == self.notesFiltered.count {
                    Notes.removeLast()
                    self.notesFiltered.removeLast()
                } else {
                    let indexOfItem = Notes.firstIndex(where: {
                        $0[0] == self.notesFiltered[a.row][0] &&
                            $0[1] == self.notesFiltered[a.row][1] &&
                            $0[2] == self.notesFiltered[a.row][2]
                    })!
                    Notes.remove(at: indexOfItem)
                    self.notesFiltered.remove(at: a.row)
                }
            }
            self.HomePageInformationTableView.deleteRows(at: self.HomePageInformationTableView.indexPathsForSelectedRows!, with: .left)
            self.HomePageInformationTableView.reloadData()
            self.HomePageTrash.isEnabled = false
        }))
        DispatchQueue.main.async {
            self.present(al, animated: true, completion: nil)
        }
    }
    
    // MARK: Photo Library Button Configuartion
    @IBOutlet weak var HomePagePhotoLibrary: UIButton!
    @IBAction func HomePagePhotoLibraryButton(_ sender: UIButton) {
        let al = UIAlertController(title: "Choose an option", message: "", preferredStyle: .actionSheet)
        al.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        al.addAction(UIAlertAction(title: "Choose Photo from Library", style: .default, handler: { (action) in
            self.editingOff()
            self.stopSearching()
            let image = UIImagePickerController()
            image.delegate = self
            image.sourceType = UIImagePickerController.SourceType.photoLibrary
            image.allowsEditing = true
            self.present(image, animated: true) {
                
            }
        }))
        al.addAction(UIAlertAction(title: "Choose PDF from Files", style: .default, handler: { (action) in
            let documentPicker = UIDocumentPickerViewController(documentTypes: ["com.adobe.pdf"], in: .import)
            documentPicker.delegate = self
            documentPicker.allowsMultipleSelection = false
            documentPicker.modalPresentationStyle = .automatic
            self.present(documentPicker, animated: true, completion: nil)
        }))
        self.present(al, animated: true, completion: nil)
    }
    
    // MARK: Take Photo Button Configuartion
    @IBOutlet weak var HomePageCamera: UIButton!
    @IBAction func HomePageCameraButton(_ sender: UIButton) {
        editingOff()
        stopSearching()
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerController.SourceType.camera
        image.allowsEditing = true
        self.present(image, animated: true) {
            
        }
    }
    
    // MARK: Scan Documents Button Configuartion
    @IBOutlet weak var HomePageScanDocuments: UIButton!
    @IBAction func HomePageScanDocumentsButton(_ sender: UIButton) {
        let vc = VNDocumentCameraViewController()
        vc.delegate = self
        self.present(vc, animated: true)
        self.HomePageInformationTableView.reloadData()
    }
    
    // MARK: Other IBOutlet Declaration
    @IBOutlet weak var HomePageInformationTableView: UITableView!
    @IBOutlet weak var HomePageSearchBar: UISearchBar!
    @IBOutlet weak var HomePageLoadingLabel: UILabel!
    @IBOutlet weak var HomePageLoadingIcon: UIActivityIndicatorView!
    
    
    // MARK: TableView Setup
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notesFiltered.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let Cell = tableView.dequeueReusableCell(withIdentifier: "TextCell", for: indexPath) as! HomePageTVCell
        Cell.HomePageTVCellTitle.text = notesFiltered[indexPath.row][0]
        Cell.HomePageTVCellContent.text = notesFiltered[indexPath.row][1]
        return Cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            if tableView.indexPathsForSelectedRows!.count >= 1 {
                HomePageTrash.isEnabled = true
            }
        } else {
            ind = Notes.firstIndex(where: {
                $0[0] == notesFiltered[indexPath.row][0] &&
                    $0[1] == notesFiltered[indexPath.row][1] &&
                    $0[2] == notesFiltered[indexPath.row][2]
            })!
            self.performSegue(withIdentifier: "toFullNoteSegue", sender: self)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            if tableView.indexPathForSelectedRow == nil {
                HomePageTrash.isEnabled = false
            }
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "") { (action, view, bool) in
            let al = UIAlertController(title: "Delete", message: "Are you sure you wish to delete this note. This action cannot be reversed!", preferredStyle: .actionSheet)
            al.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                bool(false)
            }))
            al.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
                let indexOfItem = Notes.firstIndex(where: {
                    $0[0] == self.notesFiltered[indexPath.row][0] &&
                        $0[1] == self.notesFiltered[indexPath.row][1] &&
                        $0[2] == self.notesFiltered[indexPath.row][2]
                })!
                Notes.remove(at: indexOfItem)
                self.notesFiltered.remove(at: indexPath.row)
                self.HomePageInformationTableView.deleteRows(at: [indexPath], with: .left)
                self.HomePageInformationTableView.reloadData()
            }))
            self.present(al, animated: true, completion: nil)
        }
        delete.image = UIImage(systemName: "trash")
        delete.backgroundColor = .systemRed
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let copyToClipboard = UIContextualAction(style: .normal, title: "") { (action, view, bool) in
            UIPasteboard.general.strings = []
            UIPasteboard.general.string = self.notesFiltered[indexPath.row][1]
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            bool(true)
        }
        copyToClipboard.image = UIImage(systemName: "doc.on.clipboard")
        copyToClipboard.backgroundColor = .systemGray3
        return UISwipeActionsConfiguration(actions: [copyToClipboard])
    }
    
    // MARK: Searching Functions
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        changeSearchText(searchText: searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        notesFiltered = Notes
        HomePageInformationTableView.reloadData()
        searchBar.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    func changeSearchText(searchText: String) {
        if searchText.isEmpty {
            notesFiltered = Notes
        } else {
            notesFiltered = Notes
            notesFiltered = notesFiltered.filter({
                $0[0].lowercased().contains(searchText.lowercased()) || $0[1].lowercased().contains(searchText.lowercased())
            })
        }
        HomePageInformationTableView.reloadData()
    }
    
    func stopSearching() {
        HomePageSearchBar.text = ""
        notesFiltered = Notes
        HomePageInformationTableView.reloadData()
    }
    
    // MARK: Image Handling
    func getTextFromImage(theImage: UIImage, notDocument: Bool, theImages: [UIImage]) -> String {
        
        self.HomePageLoadingIcon.isHidden = false
        self.HomePageLoadingLabel.isHidden = false
        self.HomePageLoadingIcon.startAnimating()
        
        var totalText = String()
        var totalImageText = String()
        var countImages = Int()
        
        let request = VNRecognizeTextRequest { request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                fatalError("Received invalid observations")
            }
            
            for observation in observations {
                guard let bestCandidate = observation.topCandidates(1).first else {
                    print("No candidate")
                    continue
                }
                totalText = totalText + bestCandidate.string + " "
            }
            
            if notDocument {
                let noteTitle = "Note \(Notes.count)"
                Notes.append([noteTitle, totalText, "unpinned"])
                self.global.saveData()
                self.notesFiltered = Notes
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadTV"), object: self)
                }
            } else {
                totalImageText = totalImageText + totalText + "\n\n\n"
                print(totalImageText)
                countImages += 1
                let noteTitle = "Note \(Notes.count)"
                print("Appending")
                DispatchQueue.main.async {
                    self.HomePageLoadingLabel.text = "Loading Image \(countImages)..."
                }
                if countImages == 1 {
                    Notes.append([noteTitle, totalImageText, "unpinned"])
                } else if countImages == theImages.count {
                    Notes[Notes.count - 1][1] = totalImageText
                    self.global.saveData()
                    self.notesFiltered = Notes
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadTV"), object: self)
                    }
                } else {
                    Notes[Notes.count - 1][1] = totalImageText
                }
                self.global.saveData()
            }
        }
        
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        let requests = [request]
        var image = theImage.cgImage
        if theImages.isEmpty {
            DispatchQueue.global(qos: .userInitiated).async {
                guard let img = image else {
                    fatalError("Missing image to scan")
                }

                let handler = VNImageRequestHandler(cgImage: img, options: [:])
                try? handler.perform(requests)
            }
        } else {
            for a in 0..<theImages.count {
                image = theImages[a].cgImage
                DispatchQueue.global(qos: .userInitiated).async {
                    guard let img = image else {
                        fatalError("Missing image to scan")
                    }

                    let handler = VNImageRequestHandler(cgImage: img, options: [:])
                    try? handler.perform(requests)
                }
            }
        }
        
        return totalText
    }
    
    @objc func reloadTableView() {
        self.HomePageLoadingIcon.stopAnimating()
        self.HomePageLoadingIcon.isHidden = true
        self.HomePageLoadingLabel.isHidden = true
        self.HomePageInformationTableView.reloadData()
    }
    
    // MARK: Image Taking/Retrieving
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            getTextFromImage(theImage: image, notDocument: true, theImages: [])
        } else {
            
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        var appendingText = String()
        if scan.pageCount == 1 {
            self.dismiss(animated: true, completion: nil)
            getTextFromImage(theImage: scan.imageOfPage(at: 0), notDocument: true, theImages: [])
        } else if scan.pageCount > 1 {
            self.dismiss(animated: true, completion: nil)
            var images = [UIImage]()
            for a in 0..<scan.pageCount {
                images.append(scan.imageOfPage(at: a))
            }
            appendingText = appendingText + getTextFromImage(theImage: UIImage(), notDocument: false, theImages: images)
        }
        
    }
    
    // MARK: PDF & Document Handling Handling
    func drawPDFtoImages(url: URL) {
        let document = CGPDFDocument(url as CFURL)
        var page = document!.page(at: 1)
        if document?.numberOfPages == 1 {
            let pageRect = page!.getBoxRect(.mediaBox)
            let renderer = UIGraphicsImageRenderer(size: pageRect.size)
            let img = renderer.image { ctx in
                UIColor.white.set()
                ctx.fill(pageRect)

                ctx.cgContext.translateBy(x: 0.0, y: pageRect.size.height)
                ctx.cgContext.scaleBy(x: 1.0, y: -1.0)

                ctx.cgContext.drawPDFPage(page!)
            }
            getTextFromImage(theImage: img, notDocument: true, theImages: [])
        } else {
            var images = [UIImage]()
            for a in 0..<document!.numberOfPages {
                page = document!.page(at: a + 1)
                let pageRect = page!.getBoxRect(.mediaBox)
                let renderer = UIGraphicsImageRenderer(size: pageRect.size)
                let img = renderer.image { ctx in
                    UIColor.white.set()
                    ctx.fill(pageRect)

                    ctx.cgContext.translateBy(x: 0.0, y: pageRect.size.height)
                    ctx.cgContext.scaleBy(x: 1.0, y: -1.0)

                    ctx.cgContext.drawPDFPage(page!)
                }
                images.append(img)
            }
            getTextFromImage(theImage: UIImage(), notDocument: false, theImages: images)
        }
    }
    
//    func documentBrowser(_ controller: UIDocumentBrowserViewController, didPickDocumentsAt documentURLs: [URL]) {
//        guard let sourceURL = documentURLs.first else { return }
//        drawPDFtoImages(url: sourceURL)
//    }
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let sourceURL = urls.first else { return }
        drawPDFtoImages(url: sourceURL)
    }
    
    // MARK: Segue Preparing
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! ViewNotePage
        vc.noteIndex = ind
    }
    
    
    // MARK: View Did/Will...
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        HomePageTrash.isHidden = true
        HomePageTrash.isEnabled = false
        HomePageLoadingIcon.isHidden = true
        HomePageLoadingLabel.isHidden = true
        notesFiltered = Notes
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableView), name: NSNotification.Name(rawValue: "reloadTV"), object: nil)
        
        HomePageCamera.layer.cornerRadius = 26
        HomePageEdit.layer.cornerRadius = 23
        HomePagePhotoLibrary.layer.cornerRadius = 26
        HomePageScanDocuments.layer.cornerRadius = 26
        
        HomePageInformationTableView.rowHeight = 60
        HomePageInformationTableView.estimatedRowHeight = 60
        HomePageInformationTableView.dataSource = self
        HomePageInformationTableView.delegate = self
        HomePageInformationTableView.allowsMultipleSelectionDuringEditing = true
        
        HomePageSearchBar.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        notesFiltered = Notes
        HomePageInformationTableView.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
}

extension UITableView {
    func setEmptyConditions(title: String, message: String, width: CGFloat, height: CGFloat, center: CGPoint, iconImageTitle: String) {
        let emptyView = UIView(frame: CGRect(x: center.x, y: center.y, width: width, height: height))
        let titleLabel = UILabel()
        let messageLabel = UILabel()
        let icon = UIImageView()
        var iconHeight = CGFloat()
        if iconImageTitle.isEmpty {
            icon.image = UIImage()
        } else {
            icon.image = UIImage(systemName: iconImageTitle, withConfiguration: UIImage.SymbolConfiguration(pointSize: 80))
            icon.tintColor = .label
        }
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.contentMode = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = UIColor.label
        titleLabel.font = UIFont(name: "Futura", size: 20)
        titleLabel.textAlignment = .center
        messageLabel.textColor = UIColor.secondaryLabel
        messageLabel.font = UIFont(name: "Futura", size: 17)
        emptyView.addSubview(titleLabel)
        emptyView.addSubview(messageLabel)
        emptyView.addSubview(icon)
        iconHeight = icon.image!.size.height
        icon.rightAnchor.constraint(equalTo: emptyView.rightAnchor, constant: -20).isActive = true
        icon.leftAnchor.constraint(equalTo: emptyView.leftAnchor, constant: 20).isActive = true
        icon.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -40).isActive = true
        icon.heightAnchor.constraint(equalToConstant: iconHeight).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: emptyView.rightAnchor, constant: -20).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor, constant: 20).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor, constant: 20).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: emptyView.leftAnchor, constant: 20).isActive = true
        messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20).isActive = true
        messageLabel.leftAnchor.constraint(equalTo: emptyView.leftAnchor, constant: 20).isActive = true
        messageLabel.rightAnchor.constraint(equalTo: emptyView.rightAnchor, constant: -20).isActive = true
        titleLabel.text = title
        messageLabel.text = message
        messageLabel.numberOfLines = 0
        titleLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        // The only tricky part is here:
        self.backgroundView = emptyView
        self.separatorStyle = .none
    }
    func restoreFromEmpty() {
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
}

