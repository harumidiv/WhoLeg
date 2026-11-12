import AppKit
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

let fm = FileManager.default
let root = URL(fileURLWithPath: CommandLine.arguments[1])
let references = URL(fileURLWithPath: CommandLine.arguments[2])
let copy = try JSONSerialization.jsonObject(with: Data(contentsOf: root.appendingPathComponent("tools/copy.json"))) as! [String: [String: String]]
func load(_ path: URL) -> CGImage {
    guard let src = CGImageSourceCreateWithURL(path as CFURL, nil), let img = CGImageSourceCreateImageAtIndex(src, 0, nil) else { fatalError("Missing image: \(path.path)") }
    return img
}
let ref0 = load(references.appendingPathComponent("2007x2853bb_0.png"))
let ref1 = load(references.appendingPathComponent("2007x2853bb_1.png"))
func color(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat) -> CGColor { CGColor(srgbRed:r/255, green:g/255, blue:b/255, alpha:1) }
// Sample the reference's neutral canvas so retained illustrations have seamless edges.
let sample = ref0.cropping(to: CGRect(x:1000,y:1100,width:1,height:1))!
var pixel = [UInt8](repeating:0,count:4)
let sampleContext = CGContext(data:&pixel,width:1,height:1,bitsPerComponent:8,bytesPerRow:4,space:CGColorSpace(name:CGColorSpace.sRGB)!,bitmapInfo:CGImageAlphaInfo.premultipliedLast.rawValue)!
sampleContext.draw(sample,in:CGRect(x:0,y:0,width:1,height:1))
let background = color(CGFloat(pixel[0]),CGFloat(pixel[1]),CGFloat(pixel[2]))

func drawImage(_ image: CGImage, in rect: CGRect, context ctx: CGContext) {
    ctx.saveGState()
    ctx.translateBy(x:rect.minX,y:rect.maxY)
    ctx.scaleBy(x:1,y:-1)
    ctx.draw(image,in:CGRect(origin:.zero,size:rect.size))
    ctx.restoreGState()
}
var artworkCache: [String:CGImage] = [:]
func patch(_ image: CGImage, _ crop: CGRect, _ rect: CGRect, _ ctx: CGContext) {
    let key = "\(image === ref0)-\(crop)"
    if let cached=artworkCache[key] { drawImage(cached,in:rect,context:ctx);return }
    let cropped=image.cropping(to:crop)!
    if crop.minX != 650 && crop.minX != 1720 {
        artworkCache[key]=cropped;drawImage(cropped,in:rect,context:ctx);return
    }
    let width=cropped.width,height=cropped.height
    var rgba=[UInt8](repeating:0,count:width*height*4)
    let raster=CGContext(data:&rgba,width:width,height:height,bitsPerComponent:8,bytesPerRow:width*4,space:CGColorSpace(name:CGColorSpace.sRGB)!,bitmapInfo:CGImageAlphaInfo.premultipliedLast.rawValue)!
    raster.draw(cropped,in:CGRect(x:0,y:0,width:width,height:height))
    // Exclude the tiny pieces of the old frame outside each illustration.
    for y in 0..<height { for x in 0..<width {
        if (crop.minX == 650 && CGFloat(y)>440+CGFloat(x)*0.8) || (crop.minX == 1720 && x+y<65) {
            let i=(y*width+x)*4;rgba[i]=0;rgba[i+1]=0;rgba[i+2]=0;rgba[i+3]=0
        }
    }}
    // Remove only neutral background connected to a crop corner. Closed outlines
    // retain neutral colors inside the artwork, including the fish's white body.
    var seen=[Bool](repeating:false,count:width*height)
    var queue=[0,width-1,(height-1)*width,width*height-1]
    var head=0
    while head<queue.count {
        let p=queue[head];head += 1
        if seen[p] { continue };seen[p]=true
        let i=p*4
        let low=min(rgba[i],rgba[i+1],rgba[i+2]),high=max(rgba[i],rgba[i+1],rgba[i+2])
        guard rgba[i+3] == 0 || (low>100 && Int(high)-Int(low)<24) else { continue }
        rgba[i]=0;rgba[i+1]=0;rgba[i+2]=0;rgba[i+3]=0
        let x=p%width,y=p/width
        if x>0 { queue.append(p-1) };if x+1<width { queue.append(p+1) }
        if y>0 { queue.append(p-width) };if y+1<height { queue.append(p+width) }
    }
    let provider=CGDataProvider(data:Data(rgba) as CFData)!
    let clean=CGImage(width:width,height:height,bitsPerComponent:8,bitsPerPixel:32,bytesPerRow:width*4,space:CGColorSpace(name:CGColorSpace.sRGB)!,bitmapInfo:CGBitmapInfo(rawValue:CGImageAlphaInfo.premultipliedLast.rawValue),provider:provider,decode:nil,shouldInterpolate:true,intent:.defaultIntent)!
    artworkCache[key]=clean
    drawImage(clean,in:rect,context:ctx)
}
func font(_ size: CGFloat, _ weight: NSFont.Weight) -> NSFont {
    let system = NSFont.systemFont(ofSize:size,weight:weight)
    return NSFont(descriptor:system.fontDescriptor.withDesign(.rounded) ?? system.fontDescriptor,size:size)!
}
func text(_ string: String, in rect: CGRect, size: CGFloat, weight: NSFont.Weight, color: NSColor, singleLine: Bool) {
    let paragraph = NSMutableParagraphStyle()
    paragraph.lineBreakMode = .byWordWrapping
    paragraph.lineSpacing = size * 0.08
    var actual = size
    func attributes() -> [NSAttributedString.Key: Any] {
        [.font:font(actual,weight),.foregroundColor:color,.paragraphStyle:paragraph]
    }
    if singleLine {
        while ((string as NSString).size(withAttributes:attributes()).width > rect.width || (string as NSString).size(withAttributes:attributes()).height > rect.height) && actual > size * 0.40 { actual -= 1 }
    } else {
        while (string as NSString).boundingRect(with:rect.size,options:[.usesLineFragmentOrigin,.usesFontLeading],attributes:attributes()).height > rect.height && actual > size * 0.55 { actual -= 1 }
    }
    (string as NSString).draw(with:rect,options:[.usesLineFragmentOrigin,.usesFontLeading],attributes:attributes())
}
func save(_ ctx: CGContext, _ url: URL) {
    let image = ctx.makeImage()!
    let dest = CGImageDestinationCreateWithURL(url as CFURL,UTType.png.identifier as CFString,1,nil)!
    CGImageDestinationAddImage(dest,image,nil)
    precondition(CGImageDestinationFinalize(dest))
}
let devices: [(String,Int,Int)] = [("iPhone",1206,2622),("iPhone-Duo",2007,2853),("iPad",2064,2752)]
let onlyLanguages = Array(CommandLine.arguments.dropFirst(3))
for (device, wi, hi) in devices {
    let w=CGFloat(wi), h=CGFloat(hi)
    for language in copy.keys.sorted() where onlyLanguages.isEmpty || onlyLanguages.contains(language) {
        let screenURL=root.appendingPathComponent("captures/\(device)/\(language).png")
        let screen=load(screenURL)
        precondition(screen.width == wi && screen.height == hi,"Capture has unexpected size")
        let folder=root.appendingPathComponent("exports/\(language)/\(device)")
        try fm.createDirectory(at:folder,withIntermediateDirectories:true)
        for panel in 0...1 {
            autoreleasepool {
                let ctx=CGContext(data:nil,width:wi,height:hi,bitsPerComponent:8,bytesPerRow:0,space:CGColorSpace(name:CGColorSpace.sRGB)!,bitmapInfo:CGImageAlphaInfo.noneSkipLast.rawValue)!
                ctx.translateBy(x:0,y:h); ctx.scaleBy(x:1,y:-1)
                let old=NSGraphicsContext.current
                NSGraphicsContext.current=NSGraphicsContext(cgContext:ctx,flipped:true)
                defer { NSGraphicsContext.current=old }
                ctx.setFillColor(background);ctx.fill(CGRect(x:0,y:0,width:w,height:h))
                // Decorative artwork retains the reference placement and proportions.
                if panel == 0 {
                    patch(ref0,CGRect(x:0,y:0,width:2007,height:470),CGRect(x:0,y:0,width:w,height:w*470/2007),ctx)
                    patch(ref0,CGRect(x:0,y:1380,width:1000,height:380),CGRect(x:0,y:h*0.49,width:w*1000/2007,height:w*380/2007),ctx)
                    patch(ref0,CGRect(x:0,y:2260,width:660,height:593),CGRect(x:0,y:h-w*593/2007,width:w*660/2007,height:w*593/2007),ctx)
                } else {
                    patch(ref1,CGRect(x:0,y:0,width:100,height:120),CGRect(x:0,y:0,width:w*100/2007,height:w*120/2007),ctx)
                    patch(ref1,CGRect(x:650,y:0,width:600,height:550),CGRect(x:w*650/2007,y:0,width:w*600/2007,height:w*550/2007),ctx)
                    patch(ref1,CGRect(x:1350,y:0,width:657,height:750),CGRect(x:w*1350/2007,y:0,width:w*657/2007,height:w*750/2007),ctx)
                    patch(ref1,CGRect(x:1720,y:1800,width:287,height:1053),CGRect(x:w*1720/2007,y:h-w*1053/2007,width:w*287/2007,height:w*1053/2007),ctx)
                }
                // One continuous device crosses the seam between the two exports.
                ctx.saveGState()
                ctx.translateBy(x:w*(1.27-CGFloat(panel)),y:h*0.155)
                ctx.rotate(by:42 * .pi/180)
                let dw=w*0.88, bezel=dw*0.033
                let sw=dw-2*bezel, sh=sw*CGFloat(screen.height)/CGFloat(screen.width)
                let dh=sh+2*bezel, radius=dw*0.085
                let outer=CGPath(roundedRect:CGRect(x:0,y:0,width:dw,height:dh),cornerWidth:radius,cornerHeight:radius,transform:nil)
                ctx.setShadow(offset:CGSize(width:0,height:dw*0.008),blur:dw*0.055,color:CGColor(gray:0,alpha:0.24))
                ctx.addPath(outer);ctx.setFillColor(color(154,152,143));ctx.fillPath()
                ctx.setShadow(offset:.zero,blur:0,color:nil)
                let frame=CGPath(roundedRect:CGRect(x:dw*0.004,y:dw*0.004,width:dw*0.992,height:dh-dw*0.008),cornerWidth:radius-dw*0.004,cornerHeight:radius-dw*0.004,transform:nil)
                ctx.addPath(frame);ctx.setFillColor(CGColor(gray:0.015,alpha:1));ctx.fillPath()
                ctx.addPath(CGPath(roundedRect:CGRect(x:bezel,y:bezel,width:sw,height:sh),cornerWidth:radius-bezel,cornerHeight:radius-bezel,transform:nil));ctx.clip()
                drawImage(screen,in:CGRect(x:bezel,y:bezel,width:sw,height:sh),context:ctx)
                if device == "iPad" {
                    // Keep the promotional frame free of the simulator's system-language
                    // date and app name, while leaving the app's own navigation intact.
                    ctx.setFillColor(background)
                    ctx.fill(CGRect(x:bezel,y:bezel,width:sw,height:sw*70/2064))
                }
                ctx.restoreGState()
                if panel == 0 {
                    text(copy[language]!["title"]!,in:CGRect(x:w*0.06,y:h*0.195,width:w*0.89,height:h*0.14),size:w*0.142,weight:.regular,color:NSColor(srgbRed:0.035,green:0.43,blue:0.18,alpha:1),singleLine:true)
                    text(copy[language]!["subtitle"]!,in:CGRect(x:w*0.065,y:h*0.323,width:w*0.88,height:h*0.115),size:w*0.046,weight:.medium,color:NSColor(srgbRed:0.36,green:0.35,blue:0.42,alpha:1),singleLine:false)
                }
                save(ctx,folder.appendingPathComponent("\(panel == 0 ? "01" : "02")-\(wi)x\(hi).png"))
            }
        }
        print("Rendered \(device) \(language)")
    }
}
