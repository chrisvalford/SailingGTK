import CGtk
import Foundation
import GLibObject
import Gtk
import OpenCombine

// Raspberry-pi 7" screen
let screenWidth = 800
let screenHeight = 480

func toRadians(degrees: Double) -> Double {
    return degrees * Double.pi / 180
}

func tickLength(value: Int) -> Double {
    switch value {
    case 0:
        return 10
    case 9:
        return 10
    case 18:
        return 10
    case 27:
        return 10
    default:
        return 5
    }
}

var windAngle = 105.0

var model = Model()
var windVelocity = 0.0
var subscriber = model.publisher.sink(receiveValue: { value  in
    // print(value)
    windVelocity = value
})

var heading = 43.5
var headingMode = "T" // or "M"
var windMode = "T" // or "A"
var windDisplayMode = "C" // or "N"

var drawingArea: DrawingArea!

let status = Application.run { app in

    let window = ApplicationWindowRef(application: app)
    window.title = "Wind"
    window.setDefaultSize(width: screenWidth, height: screenHeight)

    let mainBox = Box(orientation: .horizontal, spacing: 10)
    let leftBox = Box(orientation: .vertical, spacing: 10)
    let rightBox = Box(orientation: .vertical, spacing: 10)

// Left panel items
    drawingArea = DrawingArea()
    drawingArea.setSizeRequest(width: 300, height: 300)
    leftBox.add(widget: drawingArea)
    leftBox.add(widget: Separator(orientation: .horizontal))
    
    let windModeBox = Box(orientation: .horizontal, spacing: 10)
    let windModeLabel = Label(text: "Mode")
    let windModeButton = Button(label: windDisplayMode == "T" ? "True" : "Apparent")
    windModeButton.onClicked { _ in
        if windMode == "T" {
            windMode = "A"
            windModeButton.label = "True"
        } else {
            windMode = "T"
            windModeButton.label = "Apparent"
        }
    }
    
    let windDisplayModeLabel = Label(text: "Display")
    let windDisplayModeButton = Button(label: windDisplayMode == "N" ? "North UP" : "Course UP")
    windDisplayModeButton.onClicked { _ in
        if windDisplayMode == "N" {
            windDisplayMode = "C"
            windDisplayModeButton.label = "Course UP"
        } else {
            windDisplayMode = "N"
            windDisplayModeButton.label = "North UP"
        }
    }
    
    windModeBox.add(windModeLabel)
    windModeBox.add(windModeButton)
    windModeBox.add(widget: Separator(orientation: .vertical))
    windModeBox.add(windDisplayModeLabel)
    windModeBox.add(windDisplayModeButton)
    leftBox.add(windModeBox)

    // Right panel items
    let headingModeBox = Box(orientation: .horizontal, spacing: 10)
    let headingModeLabel = Label(text: "Heading")
    headingModeBox.add(headingModeLabel)
    let headingFrame = Frame()
    headingFrame.set(borderWidth: 4)
    let headingLabel = Label(text: "\(heading) (\(headingMode == "T" ? "T" : "M"))")
    headingLabel.setSizeRequest(width: 100, height: 30)
    headingFrame.add(headingLabel)
    headingModeBox.add(headingFrame)
    let headingModeButton = Button(label: headingMode == "T" ? "True" : "Magnetic")
    headingModeButton.onClicked { _ in
        if headingMode == "T" {
            headingMode = "M"
            headingModeButton.label = "Magnetic"
        } else {
            headingMode = "T"
            headingModeButton.label = "True"
        }
        headingLabel.text = "\(heading) (\(headingMode == "T" ? "T" : "M"))"
    }
    headingModeBox.add(headingModeButton)
    
    rightBox.add(headingModeBox)
    mainBox.add(leftBox)
    mainBox.add(widget: Separator(orientation: .vertical))
    mainBox.add(rightBox)
    window.add(mainBox)

    let r = 100.0    // disc radius
    let x = 150.0       // position
    let y = 150.0

     drawingArea.onDraw {
        let cr = $1 // cairo drawing context

        // Draw face
        cr.setSource(red: 0, green: 0, blue: 0)
        cr.arc(xc: x, yc: y, radius: r)
        cr.fill()
        
        // Draw ticks
        // These values seem to be rotated 90 degrees anti-clockwise, starts at 90 degrees
        cr.setSource(red: 1.0, green: 1.0, blue: 1.0)
        for i in 0..<36 {
            let value = Double(i)
     	    cr.save()
     	    cr.lineCap = CAIRO_LINE_CAP_ROUND
     	    cr.moveTo(
     	    x + (r - tickLength(value: i)) * cos (value * Double.pi / (18)),
     	    y + (r - tickLength(value: i)) * sin (value * Double.pi / 18))
            // print("Tick length for \(i) is: \(tickLength(value: i))")
     	    cr.lineTo(
     	    x + (r * cos (value * Double.pi / 18)),
     	    y + (r * sin (value * Double.pi / 18)))
     	    cr.stroke()
     	    cr.restore()
        }

        // Draw the numbers
        // TODO: change the fixed values
        cr.fontSize = 20.0
        cr.save()
        cr.moveTo(x - 6, 32)
        cr.showText("0")
        cr.moveTo(260, y + 7)
        cr.showText("90")
        cr.moveTo(x - 20, 278)
        cr.showText("180")
        cr.moveTo(6, y + 7)
        cr.showText("270")
        cr.restore()

        // Draw the velocity value box
        cr.save()
        let boxWidth = 80.0
        let boxHeight = 30.0
        // TODO: Make this a rounded rectangle with a different border color
        cr.rectangle(x: x - (boxWidth / 2), y: y - 54, width: boxWidth, height: boxHeight)
        cr.setSource(red: 0.2, green: 0.2, blue: 0.2)
        cr.fill()
        cr.restore()

        // Draw velocity
        cr.save()
        cr.moveTo(x - (boxWidth / 2) + 10, y - 32)
        cr.showText("\(windVelocity) kts")
        cr.restore()

        // Draw the direction value box
        cr.save()
        // TODO: Make this a rounded rectangle with a different border color
        cr.rectangle(x: x - (boxWidth / 2), y: y + 30, width: boxWidth, height: boxHeight)
        cr.setSource(red: 0.2, green: 0.2, blue: 0.2)
        cr.fill()
        cr.restore()

        // Draw direction value
        cr.save()
        cr.moveTo(x - (boxWidth / 2) + 10, y + 52)
        cr.showText("\(Int(windAngle))(\(windMode))")
        cr.restore()

        // Draw the pointer
        cr.save()
        cr.setSource(red: 1.0, green: 0, blue: 0)
        cr.lineWidth = 6.0
        cr.moveTo(x, y) 
        cr.lineTo(
            x + sin(toRadians(degrees: windAngle)) * (r * 0.95), 
            y + -cos(toRadians(degrees: windAngle)) * (r * 0.95)
        )
        cr.stroke()
        cr.restore()

        return false
    }
    window.showAll()
}

guard let status = status else {
    fatalError("Could not create Application")
}
guard status == 0 else {
    fatalError("Application exited with status \(status)")
}
