import Foundation
import OpenCombine

class Model: ObservableObject {

    // @Published private(set) var windVelocity = 10.0
    private(set) var windVelocity = 0.0
    private let windVelocityPublisher: PassthroughSubject<Double, Never>
    private var timer: DispatchSourceTimer?
    var publisher: AnyPublisher<Double, Never>

    init() {
        windVelocityPublisher = PassthroughSubject<Double, Never>()
        publisher = windVelocityPublisher.eraseToAnyPublisher()
        startTimer()
    }

    public func startTimer() {
        let queue = DispatchQueue(label: "digital.marine.my_project")
        timer = DispatchSource.makeTimerSource(queue: queue)
        timer?.schedule(deadline: .now(), repeating: 2.0, leeway: .seconds(0))
        timer?.setEventHandler { [weak self] in
            self?.timerAction()
        }
        timer?.resume()
    }

    func timerAction() {
        windVelocity += 5.0
        if windVelocity > 25 {
            windVelocity = 10.0
        }
        print("New wind velocity: \(windVelocity)")
        windVelocityPublisher.send(windVelocity)
    }

    func stopTimer() {
        timer?.cancel()
        timer = nil
    }

    deinit { 
        self.stopTimer()
    }
}