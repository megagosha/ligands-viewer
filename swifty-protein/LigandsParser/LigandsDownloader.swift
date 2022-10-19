import Foundation

class LigandDownloader {

    
    static func unzipFile(filePath: URL, dest: URL, completion: @escaping (URL?, Error?) -> Void) {
        let fileManager = FileManager()
        print("file \(filePath) dest \(dest)")
//        let currentWorkingPath = fileManager.currentDirectoryPath
//        var destinationURL = URL(fileURLWithPath: currentWorkingPath)
//        destinationURL.appendPathComponent(dest)
////        //delete
//        completion(destinationURL, nil)
//        return
        do {
            try fileManager.createDirectory(at: dest, withIntermediateDirectories: true, attributes: nil)
            try fileManager.unzipItem(at: filePath, to: dest)
            completion(dest, nil)
        }
        catch CocoaError.fileWriteFileExists {
            completion(dest, nil)
        }
        catch {
            print("Extraction of ZIP archive failed with error:\(error)")
            completion(nil, error)
        }
    }
    
    static func loadFileAsync(folderPath: URL, url: URL,  fileName: String, completion: @escaping (URL?, Error?) -> Void)
    {
        
//        let documentsUrl =  FileManager.default.urls(for: .applicationDirectory, in: .userDomainMask).first!
        
        let destinationUrl = folderPath.appendingPathComponent(fileName)
        
        if FileManager().fileExists(atPath: destinationUrl.path)
        {
            print("File already exists [\(destinationUrl.path)]")
            completion(destinationUrl, nil)
        }
        else
        {
            let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: nil)
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            let task = session.dataTask(with: request, completionHandler:
                                            {
                data, response, error in
                if error == nil
                {
                    if let response = response as? HTTPURLResponse
                    {
                        if response.statusCode == 200
                        {
                            if let data = data
                            {
                                if let _ = try? data.write(to: destinationUrl, options: Data.WritingOptions.atomic)
                                {
                                    completion(destinationUrl, error)
                                }
                                else
                                {
                                    completion(destinationUrl, error)
                                }
                            }
                            else
                            {
                                completion(destinationUrl, error)
                            }
                        }
                    }
                }
                else
                {
                    completion(destinationUrl, error)
                }
            })
            task.resume()
        }
    }
}
