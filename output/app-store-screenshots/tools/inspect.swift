import AppKit
import Vision
import ImageIO
import UniformTypeIdentifiers

let root=URL(fileURLWithPath:CommandLine.arguments[1])
let fm=FileManager.default
let languages=["en","de","fr","es","it","pt-BR","nl","pl","tr","zh-Hans","zh-Hant","ko","id","vi","th"]
let devices=[("iPhone",1206,2622),("iPhone-Duo",2007,2853),("iPad",2064,2752)]
func image(_ url:URL)->CGImage {
    let src=CGImageSourceCreateWithURL(url as CFURL,nil)!
    return CGImageSourceCreateImageAtIndex(src,0,nil)!
}
func draw(_ img:CGImage,_ rect:CGRect,_ ctx:CGContext) {
    ctx.saveGState();ctx.translateBy(x:rect.minX,y:rect.maxY);ctx.scaleBy(x:1,y:-1)
    ctx.draw(img,in:CGRect(origin:.zero,size:rect.size));ctx.restoreGState()
}
func write(_ ctx:CGContext,_ url:URL) {
    let d=CGImageDestinationCreateWithURL(url as CFURL,UTType.png.identifier as CFString,1,nil)!
    CGImageDestinationAddImage(d,ctx.makeImage()!,nil);precondition(CGImageDestinationFinalize(d))
}
let preview=root.appendingPathComponent("previews")
try fm.createDirectory(at:preview,withIntermediateDirectories:true)
for (device,w,h) in devices {
    let pairW=600, pairH=Int(Double(h)/Double(w)*300)
    let cellH=pairH+32
    let ctx=CGContext(data:nil,width:pairW*3,height:cellH*5,bitsPerComponent:8,bytesPerRow:0,space:CGColorSpace(name:CGColorSpace.sRGB)!,bitmapInfo:CGImageAlphaInfo.noneSkipLast.rawValue)!
    ctx.translateBy(x:0,y:CGFloat(cellH*5));ctx.scaleBy(x:1,y:-1)
    ctx.setFillColor(CGColor(gray:1,alpha:1));ctx.fill(CGRect(x:0,y:0,width:pairW*3,height:cellH*5))
    NSGraphicsContext.current=NSGraphicsContext(cgContext:ctx,flipped:true)
    for (index,language) in languages.enumerated() {
        let x=(index%3)*pairW,y=(index/3)*cellH
        (language as NSString).draw(at:CGPoint(x:x+8,y:y+6),withAttributes:[.font:NSFont.systemFont(ofSize:18,weight:.bold),.foregroundColor:NSColor.black])
        for panel in 0...1 {
            let img=image(root.appendingPathComponent("exports/\(language)/\(device)/\(panel==0 ? "01":"02")-\(w)x\(h).png"))
            draw(img,CGRect(x:x+panel*300,y:y+32,width:300,height:pairH),ctx)
        }
    }
    write(ctx,preview.appendingPathComponent("\(device)-all-languages.png"))
}
if CommandLine.arguments.contains("--previews-only") { exit(0) }
// OCR the unrotated device captures for a reviewable check of language and dialogs.
var reports:[[String:Any]]=[]
let request=VNRecognizeTextRequest()
request.recognitionLevel = .accurate
request.automaticallyDetectsLanguage = true
for (device,_,_) in devices {
    for language in languages {
        try autoreleasepool {
            let url=root.appendingPathComponent("captures/\(device)/\(language).png")
            request.recognitionLanguages = language == "zh-Hans" ? ["zh-Hans","en-US"] : language == "zh-Hant" ? ["zh-Hant","en-US"] : language == "ko" ? ["ko-KR","en-US"] : ["en-US","fr-FR","de-DE","es-ES","it-IT","pt-BR"]
            try VNImageRequestHandler(url:url).perform([request])
            let lines=(request.results ?? []).compactMap{$0.topCandidates(1).first?.string}
            reports.append(["device":device,"language":language,"text":lines])
            print("Inspected \(device) \(language): \(lines.joined(separator:" | "))")
        }
    }
}
try JSONSerialization.data(withJSONObject:reports,options:[.prettyPrinted,.sortedKeys]).write(to:root.appendingPathComponent("tools/capture-ocr.json"))
