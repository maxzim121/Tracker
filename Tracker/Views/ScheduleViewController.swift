import Foundation
import UIKit

final class RaspisaineViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SwitherDelegate {
    
    weak var delegate: ScheduleDelegate?
    
    private let weekDay: [WeekDay] = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
    private var schedule: [WeekDay] = []
    
    private var viewLabel = UILabel()
    private var gotovoButton = UIButton()
    private var daysTable: UITableView = {
        let daysTable = UITableView()
        daysTable.register(DaysTableCell.self, forCellReuseIdentifier: "DaysCell")
        return daysTable
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureViewLabel()
        configureDaysTable()
        configureGotovoButton()
    }
    
    private func configureViewLabel() {
        view.addSubview(viewLabel)
        viewLabel.translatesAutoresizingMaskIntoConstraints = false
        viewLabel.text = "Расписание"
        viewLabel.textAlignment = .center
        viewLabel.textColor = .black
        viewLabel.backgroundColor = .white
        viewLabel.font = .systemFont(ofSize: 16, weight: .medium)
        NSLayoutConstraint.activate([
            viewLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            viewLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            viewLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            viewLabel.heightAnchor.constraint(equalToConstant: 114)
        ])
    }
    private func configureDaysTable(){
        view.addSubview(daysTable)
        daysTable.translatesAutoresizingMaskIntoConstraints = false
        daysTable.delegate = self
        daysTable.dataSource = self
        NSLayoutConstraint.activate([
            daysTable.topAnchor.constraint(equalTo: viewLabel.bottomAnchor),
            daysTable.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            daysTable.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            daysTable.heightAnchor.constraint(equalToConstant: 525)
        ])
        daysTable.layer.cornerRadius = 16
    }
    private func configureGotovoButton(){
        view.addSubview(gotovoButton)
        gotovoButton.translatesAutoresizingMaskIntoConstraints = false
        gotovoButton.setTitle("Готово", for: .normal)
        gotovoButton.titleLabel?.textAlignment = .center
        gotovoButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        gotovoButton.backgroundColor = .black
        gotovoButton.layer.cornerRadius = 16
        NSLayoutConstraint.activate([
            gotovoButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            gotovoButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            gotovoButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            gotovoButton.heightAnchor.constraint(equalToConstant: 60),
        ])
        gotovoButton.addTarget(self, action: #selector(gotovoButtonTapped), for: .touchUpInside)
    }
    
    private func updateSchedule(flag: Bool, day: WeekDay) {
        if flag {
            var listDay: [WeekDay] = []
            listDay = schedule
            listDay.append(day)
            schedule = listDay
        } else {
            var listDay: [WeekDay] = []
            listDay = schedule
            guard let index = listDay.firstIndex(of: day) else { return }
            listDay.remove(at: index)
            schedule = listDay
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = daysTable.dequeueReusableCell(withIdentifier: "DaysCell", for: indexPath) as! DaysTableCell
        cell.dayLabel.text = weekDay[indexPath.row].day
        cell.delegate = self
        return cell
    }
    
    func switcherRecievedDay(cell: UITableViewCell, flag: Bool) {
        guard let cell = cell as? DaysTableCell,
              let indexPath = daysTable.indexPath(for: cell)
        else { return }
        let day = weekDay[indexPath.row]
        
        updateSchedule(flag: flag, day: day)
        
    }
    
    @objc private func gotovoButtonTapped() {
        guard let delegate else { return }
        delegate.scheduleRecieved(schedule: schedule)
        self.dismiss(animated: true)
    }
    
}
