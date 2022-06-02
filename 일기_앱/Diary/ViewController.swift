//
//  ViewController.swift
//  Diary
//
//  Created by 유혜빈 on 2021/11/24.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var diaryList = [Diary](){
        didSet{
            self.saveDiaryList() //diaryList배열 변경시 마다 호출되서 저장
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureCollectionView()
        self.loadDiaryList()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(editDiaryNotification(_:)),
            name: NSNotification.Name("editDiary"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(starDiaryNotification(_:)),
            name: NSNotification.Name("starDiary"),
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(deleteDiaryNotification(_:)),
            name: NSNotification.Name("deleteDiary"),
            object: nil
        )
    }
    
    @objc func editDiaryNotification(_ notification: Notification){
        guard let diary = notification.object as? Diary else {return} //post에서 보낸 객체 가져옴
        //guard let row = notification.userInfo?["indexPath.row"] as? Int else{return}
        guard let index = self.diaryList.firstIndex(where: {$0.uuidString == diary.uuidString}) else {return}//notification에서 전달받은 uuid와 같은값이 배열의 요소에 있는지 확인하고 있으면 해당 요소의 index 반환
        self.diaryList[index] = diary
        self.diaryList = self.diaryList.sorted(by: {
            $0.date.compare($1.date) == .orderedDescending //최신순 정렬
        })
        self.collectionView.reloadData()
    }
    
    @objc func starDiaryNotification(_ notification: Notification){
        guard let starDiary = notification.object as? [String: Any] else {return}
        guard let isStar = starDiary["isStar"] as? Bool else {return}
        //guard let indexPath = starDiary["indexPath"] as? IndexPath else {return}
        guard let uuidString = starDiary["uuidString"] as? String else {return}
        guard let index = self.diaryList.firstIndex(where: {$0.uuidString == uuidString}) else {return}
        self.diaryList[index].isStar = isStar
    }
    
    @objc func deleteDiaryNotification(_ notification: Notification){
        //guard let indexPath = notification.object as? IndexPath else {return}
        guard let uuidString = notification.object as? String else {return}
        guard let index = self.diaryList.firstIndex(where: {$0.uuidString == uuidString}) else {return}
        self.diaryList.remove(at: index)
        self.collectionView.deleteItems(at: [IndexPath(row: index, section: 0)])
    }
    
    //일기 내용이 collection view에 표시되도록
    private func configureCollectionView(){
        self.collectionView.collectionViewLayout = UICollectionViewFlowLayout()
        self.collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10) //collectionview에 표시되는 content 간격
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    //date타입 -> String
    private func dateToString(date: Date)->String{
        let formatter = DateFormatter()
        formatter.dateFormat = "yy년 MM월 dd일(EEEEE)"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let writeDiaryViewController = segue.destination as? WriteDiaryViewController{ //segueway로 viewcontroller 이동
            writeDiaryViewController.delegate = self //delegate 위임
        }
    }
    
    private func saveDiaryList(){
        //배열에 있는 요소들으 dic 형태로 mapping
        let date = self.diaryList.map{
            [
                "uuidString": $0.uuidString,
                "title": $0.title,
                "contents": $0.contents,
                "date": $0.date,
                "isStar": $0.isStar
            ]
        }
        let userDefaults = UserDefaults.standard // UserDefaults에 접근 가능
        userDefaults.set(date, forKey: "diaryList")
    }
    
    private func loadDiaryList(){
        let userDefaults = UserDefaults.standard // UserDefaults에 접근 가능
        guard let data = userDefaults.object(forKey: "diaryList") as? [[String: Any]] else {return} //object는 any타입으로 리턴되기 때문에 dic으로 타입캐스팅
        self.diaryList = data.compactMap{   //불러온 데이터를 diaryList에 넣어줌
            guard let uuidString = $0["uuidString"] as? String else {return nil}
            guard let title = $0["title"] as? String else{return nil}
            guard let contents = $0["contents"] as? String else{return nil}
            guard let date = $0["date"] as? Date else{return nil}
            guard let isStar = $0["isStar"] as? Bool else{return nil}
            return Diary(uuidString: uuidString, title: title, contents: contents, date: date, isStar: isStar)
        }
        //날짜순으로 정렬
        self.diaryList = self.diaryList.sorted(by: {
            $0.date.compare($1.date) == .orderedDescending //최신순 정렬
        })
    }
}

extension ViewController: WriteDiaryViewDelegate{
    func didSelectRegister(diary: Diary) { // 작성된 일기 내용을 담은 객체 받음
        self.diaryList.append(diary)
        //날짜순으로 정렬
        self.diaryList = self.diaryList.sorted(by: {
            $0.date.compare($1.date) == .orderedDescending //최신순 정렬
        })
        self.collectionView.reloadData()
    }
}

extension ViewController: UICollectionViewDataSource{
    //표시할 cell개수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.diaryList.count
    }
    //표시할 cell 요청
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiaryCell", for: indexPath) as? DiaryCell else {return UICollectionViewCell()} //storyboard에서 생성한 cell 가져옴, DiaryCell로 다운캐스팅 실패시 빈 UICollectionView 반환 => 재사용 가능한 cell 가져옴
        
        //cell에 일기의 제목과 날짜 표시
        let diary = self.diaryList[indexPath.row] //배열에 저장된 일기 가져옴
        cell.titleLabel.text = diary.title
        cell.dateLabel.text = self.dateToString(date: diary.date)
        return cell
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout{
    //표시할 cell 사이즈 설정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (UIScreen.main.bounds.width / 2) - 20, height: 200)
    }
}

extension ViewController: UICollectionViewDelegate{
    //특정 cell이 선택되었음을 알려줌
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "DiaryDetailViewController") as? DiaryDetailViewController else {return} //storyboar에 있는 viewcontroller 인스턴스화 해준 후 타입캐스팅
        let diary = self.diaryList[indexPath.row]
        viewController.diary = diary
        viewController.indexPath = indexPath
        //viewController.delegate = self
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
/*
extension ViewController: DiaryDetailViewDelegate{
    func didSelectDelete(indexPath: IndexPath) {
        self.diaryList.remove(at: indexPath.row)
        self.collectionView.deleteItems(at: [indexPath])
    }
    /*
    func didSelectStar(indexPath: IndexPath, isStar: Bool) {
        self.diaryList[indexPath.row].isStar = isStar
    }
     */
}
 */
