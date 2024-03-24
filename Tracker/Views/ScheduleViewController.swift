import UIKit

protocol ScheduleViewControllerDelegate: AnyObject {
    func daysOfWeek(viewController: UIViewController, listDays:[WeekDay])
}

//MARK: - ScheduleViewController
final class ScheduleViewController: UIViewController {
    private struct ConstantsShedulVc {
        static let spacingVerticalStack = CGFloat(20)
        static let cornerRadiusUIElement = CGFloat(16)
        static let heightCell = CGFloat(75)
        static let separatorInsetTableView = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        static let scheduleLableFont = UIFont.systemFont(ofSize: 16, weight: .medium)
    }
    
    weak var delegate: ScheduleViewControllerDelegate?
    private let viewModel: SheduleViewModelProtocol
    private let colors = Colors()
    
    private lazy var scheduleLable: UILabel = {
        let scheduleLable = UILabel()
        scheduleLable.text = Translate.scheduleLableText
        scheduleLable.font = ConstantsShedulVc.scheduleLableFont
        scheduleLable.textColor = colors.buttonEventColor
        scheduleLable.backgroundColor = .clear
        scheduleLable.textAlignment = .center
        
        return scheduleLable
    }()
    
    private lazy var weekDayTableView: UITableView = {
        let weekDayTableView = UITableView()
        weekDayTableView.dataSource = self
        weekDayTableView.delegate = self
        weekDayTableView.allowsSelection = false
        weekDayTableView.backgroundColor = .clear
        weekDayTableView.separatorInset = ConstantsShedulVc.separatorInsetTableView
        weekDayTableView.separatorColor = .separatorColor
        weekDayTableView.register(WeekDayTableViewCell.self,
                                  forCellReuseIdentifier: "\(WeekDayTableViewCell.self)")
        
        return weekDayTableView
    }()
    
    private lazy var doneButton: UIButton = {
        let doneButton = UIButton()
        doneButton.addTarget(self,
                             action: #selector(didTapDoneButton),
                             for: .touchUpInside)
        doneButton.layer.cornerRadius = ConstantsShedulVc.cornerRadiusUIElement
        doneButton.layer.masksToBounds = true
        doneButton.backgroundColor = colors.buttonDisabledColor
        doneButton.setTitle(Translate.doneButtonText, for: .normal)
        doneButton.setTitleColor(.textEventColor, for: .normal)
        
        return doneButton
    }()
    
    private var contentStackView: UIStackView = {
        let contentStackView = UIStackView()
        contentStackView.axis = .vertical
        contentStackView.backgroundColor = .clear
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        
        return contentStackView
    }()
    
    init(viewModel: SheduleViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = colors.viewBackground
        setupContentSteck()
    }
}


private extension ScheduleViewController {
    //MARK: - Обработка событий
    @objc
    func didTapDoneButton() {
        guard let delegate
        else { return }
        //передаем список дней для поля "schedule" при создании трекера
        let listDays = viewModel.listWeekDay.sorted { $0.rawValue < $1.rawValue }
        delegate.daysOfWeek(viewController: self, listDays: listDays)
        dismiss(animated: true)
    }
    
    //MARK: - Логика
    //метод обновления списка listWeekDay в зависимости от положения переключателя в яцейке weekDayTableView
    func updateListWeekDay(flag: Bool, day: WeekDay) {
        if flag {
            var listDay: [WeekDay] = []
            listDay = viewModel.listWeekDay
            listDay.append(day)
            viewModel.setListWeekDay(listWeekDay: listDay)
        } else {
            var listDay: [WeekDay] = []
            listDay = viewModel.listWeekDay
            guard let index = listDay.firstIndex(of: day) else { return }
            listDay.remove(at: index)
            viewModel.setListWeekDay(listWeekDay: listDay)
        }
    }
    
    //MARK: - SetupUI
    func setupContentSteck() {
        view.addSubview(contentStackView)
        [scheduleLable, weekDayTableView, doneButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentStackView.addArrangedSubview($0)
        }
        contentStackView.setCustomSpacing(38, after: scheduleLable)
        
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                                  constant: 16),
            contentStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                     constant: -16),
            contentStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                      constant: 16),
            contentStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                       constant: -16),
            
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}

//MARK: - UITableViewDataSource
extension ScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.weekDay.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(WeekDayTableViewCell.self)")
                as? WeekDayTableViewCell
        else { return UITableViewCell() }
        cell.delegate = self
        cell.config(nameDay: viewModel.weekDay[indexPath.row])
        if viewModel.weekDay[indexPath.row] == viewModel.weekDay.first {
            cell.setupCornerRadius(cornerRadius: ConstantsShedulVc.cornerRadiusUIElement,
                                   maskedCorners: [.layerMinXMinYCorner,
                                                   .layerMaxXMinYCorner])
            
        }
        if viewModel.weekDay[indexPath.row] == viewModel.weekDay.last {
            cell.setupCornerRadius(cornerRadius: ConstantsShedulVc.cornerRadiusUIElement,
                                   maskedCorners: [.layerMinXMaxYCorner,
                                                   .layerMaxXMaxYCorner])
            cell.separatorInset = UIEdgeInsets(top: 0,
                                               left: 0,
                                               bottom: 0,
                                               right: .greatestFiniteMagnitude)
        }
        
        return cell
    }
}

//MARK: - UITableViewDelegate
extension ScheduleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        ConstantsShedulVc.heightCell
    }
}

//MARK: - WeekDayTableViewCellDelegate
extension ScheduleViewController: WeekDayTableViewCellDelegate {
    func addDayInListkDay(cell: UITableViewCell, flag: Bool) {
        guard let cell = cell as? WeekDayTableViewCell,
              let indexPath = weekDayTableView.indexPath(for: cell)
        else { return }
        let day = viewModel.weekDay[indexPath.row]
        updateListWeekDay(flag: flag, day: day)
    }
}
