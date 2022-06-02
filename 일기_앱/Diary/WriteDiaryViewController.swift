//
//  WriteDiaryViewController.swift
//  Diary
//
//  Created by 유혜빈 on 2021/11/24.
//

import UIKit

enum DiaryEditorMode{
    case new
    case edit(IndexPath, Diary)
}

protocol WriteDiaryViewDelegate: AnyObject{
    func didSelectRegister(diary: Diary)
}

class WriteDiaryViewController: UIViewController {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var confirmButton: UIBarButtonItem!
    
    private let datePicker = UIDatePicker()
    private var diaryDate: Date?
    
    weak var delegate: WriteDiaryViewDelegate?
    var diaryEditorMode: DiaryEditorMode = .new
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureContentsTextView()
        self.configureDatePicker()
        self.configureEditMode()
        self.configureInputField()
        self.confirmButton.isEnabled = false //등록버튼 비활성화
    }
    
    //수정 버튼 클릭시
    private func configureEditMode(){
        switch self.diaryEditorMode{
        case let .edit(_, diary):
            self.titleTextField.text = diary.title
            self.contentsTextView.text = diary.contents
            self.dateTextField.text = self.dateToString(date: diary.date)
            self.diaryDate = diary.date
            self.confirmButton.title = "수정"
            
        default:
            break
        }
    }
    
    //date타입 -> String
    private func dateToString(date: Date)->String{
        let formatter = DateFormatter()
        formatter.dateFormat = "yy년 MM월 dd일(EEEEE)"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
    
    //contentsTextView에 테두리 박스 생성
    private func configureContentsTextView(){
        let borderColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0)
        self.contentsTextView.layer.borderColor = borderColor.cgColor
        self.contentsTextView.layer.borderWidth = 0.5
        self.contentsTextView.layer.cornerRadius = 5.0
    }
    //date picker 날짜 선택
    private func configureDatePicker(){
        self.datePicker.datePickerMode = .date  //날짜만
        self.datePicker.preferredDatePickerStyle = .wheels
        self.datePicker.addTarget(self, action: #selector(datePickerValueDidChange(_:)), for: .valueChanged)
        self.datePicker.locale = Locale(identifier: "ko_KR")
        self.dateTextField.inputView = self.datePicker
    }
    
    @objc func datePickerValueDidChange(_ datePicker: UIDatePicker){
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월 dd일(EEEEE)"
        formatter.locale = Locale(identifier: "ko_KR")
        self.diaryDate = datePicker.date
        self.dateTextField.text = formatter.string(from: datePicker.date)
        self.dateTextField.sendActions(for: .editingChanged) //datetextfield는 키보드로 입력받는 형태가 아니라 datepicker로 값을 변경해도 didchange메서드 호출이 안되기 때문에 action을 발생 시키는 코드 추가
    }
    
    //하나라도 비어있으면 등록버튼 비활성화
    private func configureInputField(){
        self.contentsTextView.delegate = self
        self.titleTextField.addTarget(self, action: #selector(titleTextFieldDidChange(_:)), for: .editingChanged)
        self.dateTextField.addTarget(self, action: #selector(dateTextFieldDidChange(_:)), for: .editingChanged)
    }
    
    @objc func titleTextFieldDidChange(_ textField: UITextField){
        self.validateInputField()
    }
    
    @objc func dateTextFieldDidChange(_ textField: UITextField){
        self.validateInputField()
    }
    
    //등록버튼 활성화 여부 판단
    private func validateInputField(){
        self.confirmButton.isEnabled = !(self.titleTextField.text?.isEmpty ?? true) && !(self.dateTextField.text?.isEmpty ?? true) && !self.contentsTextView.text.isEmpty //모든 inputfield가 비어있지 않으면 등록버튼 활성화
    }
    
    //등록버튼 클릭
    @IBAction func tapConfirmButton(_ sender: UIBarButtonItem) {
        //작성된 내용 구조체에 저장
        guard let title = self.titleTextField.text else {return}
        guard let contents = self.contentsTextView.text else {return}
        guard let date = self.diaryDate else {return}
        
        switch self.diaryEditorMode{
        case .new:
            let diary = Diary(
                uuidString: UUID().uuidString,
                title: title,
                contents: contents,
                date: date,
                isStar: false)
            self.delegate?.didSelectRegister(diary: diary)
        case let .edit(indexPath, diary):
            let diary = Diary(
                uuidString: diary.uuidString,
                title: title,
                contents: contents,
                date: date, isStar:
                diary.isStar ?? false)
            NotificationCenter.default.post(
                name: NSNotification.Name("editDiary"),
                object: diary,
                userInfo: nil
            )
        }
        
        //delegate로 작성된 내용 전달
        //self.delegate?.didSelectRegister(diary: diary)
        //화면을 이전화면으로 이동
        self.navigationController?.popViewController(animated: true)
    }
    
    //화면 터치시 호출되는 메서드
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true) //빈화면 누르면 데이트피커,키보드 없어짐
    }
    
}

extension WriteDiaryViewController: UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        self.validateInputField()  //textview가 바뀔때마다 등록버튼 활성화 확인
    }
}
