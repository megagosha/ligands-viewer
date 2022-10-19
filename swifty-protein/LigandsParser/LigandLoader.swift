import Foundation
import ZIPFoundation

class LigandLoader: ObservableObject {
    @Published var isReady: Bool = false
    @Published var showError: Bool = false
    
    var downloadLinks: [URL] = []
    var foldersReady: [URL] = []
    var pathsToZip: [URL] = []
    var ligandsCount: Int = 0
    public var ligands: [Ligand] = []
    init() {
        
        if let path = Bundle.main.path(forResource: "ligands", ofType: "txt") {
            let fm = FileManager()
            let exists = fm.fileExists(atPath: path)
            if (exists) {
                guard let content = fm.contents(atPath: path),
                      let contentString = String(data: content, encoding: .ascii) else {
                    fatalError("Failed to load file")
                }
                let ligandsNames = contentString.split(separator: "\n")
                ligandsCount = ligandsNames.count
                
                generateDownloadLinks(ligands: ligandsNames)
                if downloadLinks.count != 25
                {
                    fatalError("Something went wrong!")
                }
            } else {
                fatalError("Failed to load ligands")
            }
        }
        else {
            fatalError("Failed to load ligands")
        }
    }
    
    private func isLigandsReady()->Bool {
        let filename = getDocumentsDirectory().appendingPathComponent("ligansParsed.json")
        do {
            let data = try Data(contentsOf: filename, options: .mappedIfSafe)
            let res = try JSONDecoder().decode([Ligand].self, from: data)
            if res.count == ligandsCount {
                self.ligands = res
                return true;
            }
        } catch {
            // handle error
        }
        return false
    }
    
    public func start() {
        if isLigandsReady() {
            print("ready")
            print(ligands.count)
            isReady = true
            return
        }
        else {
            print("not ready")
        }
        self.downloadAndProcessBatches()
    }
    
    private func generateDownloadLinks(ligands: [String.SubSequence]) {
        var i = 0
        var url = "https://download.rcsb.org/batch/ccd/";
        let ext = "_ideal.sdf"
        for  el in ligands {
            if (i == 49) {
                url += el + ext
                appendUrlFromString(url: url)
                url = "https://download.rcsb.org/batch/ccd/"
                i = 0
                continue;
            }
            url += String(el) + ext + ":"
            i += 1
        }
        if (i != 0) {
            url.remove(at: url.index(before: url.endIndex))
            appendUrlFromString(url: url)
        }
    }
    
    private func appendUrlFromString(url: String) {
        guard let urlObj = URL(string: url) else {
            fatalError("Failed to generate url from: " + url)
        }
        self.downloadLinks.append(urlObj)
    }
    
    private func downloadAndProcessBatches() {
        
        let queue = DispatchQueue(label: "ligands_processing", qos: .userInitiated, attributes: [.concurrent])
        
        for (ix, _) in self.downloadLinks.enumerated() {
            queue.async {
                self.downloadBatch(ix: ix) { url, pathToZip in
                    if (url == nil) {
                        DispatchQueue.main.async {
                            self.showError = true
                        }
                    }
                    else {
                        //                        print("folder ready folder path \(url) \n path to zip \(pathToZip)")
                        self.foldersReady.append(url!)
                        self.parseFolder(documentDirectory: url!, zip: pathToZip!)
                        if self.ligandsCount == self.ligands.count {
                            self.saveAndClean()
                            DispatchQueue.main.async {
                                self.isReady = true
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func saveAndClean() {
        do {
            let jsonData = try JSONEncoder().encode(ligands)
            let jsonString = String(data: jsonData, encoding: .utf8)!
            let filename = getDocumentsDirectory().appendingPathComponent("ligansParsed.json")
            do {
                try jsonString.write(to: filename, atomically: true, encoding: String.Encoding.utf8)
            } catch {
                print("failed to write json result")
                DispatchQueue.main.async {
                    self.showError = true
                }
            }
            for folder in foldersReady {
                try FileManager().removeItem(at: folder)
            }
            for zipFile in pathsToZip {
                try FileManager().removeItem(at: zipFile)
            }
        }
        catch {
            print(error)
            DispatchQueue.main.async {
                self.showError = true
            }        }
    }
    
    //TODO: remove fatalError
    private func downloadBatch(ix: Int, completion: @escaping (URL?, URL?)->Void) {
        LigandDownloader.loadFileAsync(folderPath: getDocumentsDirectory(), url: self.downloadLinks[ix], fileName: "batch" + String(ix) + ".zip") { (pathToZip, error) in
            if (error != nil || pathToZip == nil) {
                self.showError = true
                //                fatalError("Failed to download file")
                completion(nil, nil)
            }
            else {
                self.pathsToZip.append(pathToZip!)
                var dest = self.getDocumentsDirectory()
                dest.appendPathComponent("batch" + String(ix))
                LigandDownloader.unzipFile(filePath: pathToZip!, dest: dest) { (path, error) in
                    if (error != nil) {
                        //TODO: clean up! Remove failed unzip
                        fatalError("Failed to unzip file")
                    }
                    completion(path, pathToZip)
                }
            }
        }
    }
    
    private func getDirContents(dir: URL)throws-> [URL] {
        let directoryContents = try FileManager.default.contentsOfDirectory(
            at: dir,
            includingPropertiesForKeys: nil
        )
        return directoryContents
    }
    
    private func parseFolder(documentDirectory: URL, zip: URL) {
        do {
            // Get the directory contents urls (including subfolders urls)
            let directoryContents = try getDirContents(dir: documentDirectory)
            //            guard let fileUrl = Bundle.main.url(forResource: "1H3_ideal", withExtension: "sdf") else { fatalError() }
            //            print("document dir \(documentDirectory)")
            //            print(directoryContents)
            for url in directoryContents {
                //                print("file \(url)")
                let text = try  String(contentsOf: url, encoding: String.Encoding.ascii)
                let ligand = Ligand(text)
                ligands.append(ligand)
            }
        } catch {
            //            clearBatch(directory: documentDirectory, zip: zip)
            print(error)
        }
    }
    
    private func clearBatch(directory: URL, zip: URL) {
        do {
            try FileManager().removeItem(at: directory)
            try FileManager().removeItem(at: zip)
        }
        catch {
            print(error)
        }
    }
    
    private func parseBatch() {
        
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
