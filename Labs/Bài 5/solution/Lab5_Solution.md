# Lab 5 — Đáp án (Dành cho Giảng viên)

> **KHÔNG chia sẻ file này cho sinh viên!**

---

## Tổng quan

Lab mô phỏng quy trình làm việc nhóm thực tế: 2 developer dùng Git Flow + Pull Request + Code Review để phát triển ứng dụng "Student Manager". Sinh viên thực hành toàn bộ vòng đời Git: init → add → commit → push → pull → branch → PR → review → merge → conflict resolution.

---

## Kết quả Mong đợi

### Cấu trúc Repository Cuối cùng

```
devops-lab5-student-manager/
├── .gitignore
├── README.md
└── src/
    ├── student.py          ← Student model class
    └── main.py             ← Main app: add + search + display
```

### Lịch sử Git Mong đợi

```
*   abc1234 (HEAD -> main, origin/main) Merge branch 'develop'
|\
| *   def5678 (develop) Merge: resolve README conflict
| |\
| | * ghi9012 (feature/update-readme-b) docs: update README - Team B
| * | jkl3456 Merge pull request #1 from feature/add-student
| |\|
| | * mno7890 (feature/add-student) feat: add add_student function
| |/
| *   pqr1234 Merge pull request #2 from feature/search-student
| |\
| | * stu5678 (feature/search-student) feat: add search_student
| |/
| * vwx9012 feat: add main application entry point
| * yza3456 feat: add Student model class
|/
* bcd6789 Initial commit: README + .gitignore
```

### Output của `python src/main.py` (cuối cùng)

```
==================================================
STUDENT MANAGER — DevOps Lab 5
==================================================
✅ Đã thêm sinh viên: Student(id=SV004, name='Pham Thi D', age=22, grade='K19')
  Student(id=SV001, name='Nguyen Van A', age=20, grade='K20')
  Student(id=SV002, name='Tran Thi B', age=21, grade='K20')
  Student(id=SV003, name='Le Van C', age=19, grade='K21')
  Student(id=SV004, name='Pham Thi D', age=22, grade='K19')

Total: 4 students

--- Tìm kiếm ---
🔍 Tìm thấy 1 sinh viên với từ khóa 'Van':
  Student(id=SV001, name='Nguyen Van A', age=20, grade='K20')
```

---

## Đáp án Code

### src/student.py (cuối cùng)

```python
"""
Student Manager — DevOps Lab 5
Module: Student Model
"""

class Student:
    """Lớp đại diện cho một sinh viên."""

    def __init__(self, student_id: str, name: str, age: int, grade: str):
        self.student_id = student_id
        self.name = name
        self.age = age
        self.grade = grade

    def __str__(self) -> str:
        return f"Student(id={self.student_id}, name='{self.name}', age={self.age}, grade='{self.grade}')"

    def to_dict(self) -> dict:
        """Chuyển đối tượng Student thành dictionary."""
        return {
            "student_id": self.student_id,
            "name": self.name,
            "age": self.age,
            "grade": self.grade,
        }


if __name__ == "__main__":
    s1 = Student("SV001", "Nguyen Van A", 20, "K20")
    print(s1)
    print(s1.to_dict())
```

### src/main.py (cuối cùng — sau khi merge cả 2 features)

```python
"""
Student Manager — DevOps Lab 5
Module: Main Application
"""
from student import Student


def add_student(students: list, student_id: str, name: str, age: int, grade: str) -> list:
    """Thêm sinh viên mới vào danh sách."""
    for s in students:
        if s.student_id == student_id:
            print(f"❌ Mã sinh viên {student_id} đã tồn tại!")
            return students

    new_student = Student(student_id, name, age, grade)
    students.append(new_student)
    print(f"✅ Đã thêm sinh viên: {new_student}")
    return students


def search_student(students: list, keyword: str) -> list:
    """Tìm kiếm sinh viên theo tên hoặc mã."""
    results = []
    keyword_lower = keyword.lower()

    for s in students:
        if keyword_lower in s.name.lower() or keyword_lower in s.student_id.lower():
            results.append(s)

    if results:
        print(f"🔍 Tìm thấy {len(results)} sinh viên với từ khóa '{keyword}':")
        for s in results:
            print(f"  {s}")
    else:
        print(f"❌ Không tìm thấy sinh viên nào với từ khóa '{keyword}'")

    return results


def main():
    """Hàm chính của ứng dụng."""
    print("=" * 50)
    print("STUDENT MANAGER — DevOps Lab 5")
    print("=" * 50)

    students = [
        Student("SV001", "Nguyen Van A", 20, "K20"),
        Student("SV002", "Tran Thi B", 21, "K20"),
        Student("SV003", "Le Van C", 19, "K21"),
    ]

    # Thêm sinh viên mới (Dev A's feature)
    students = add_student(students, "SV004", "Pham Thi D", 22, "K19")

    # Hiển thị danh sách
    for student in students:
        print(f"  {student}")
    print(f"\nTotal: {len(students)} students")

    # Tìm kiếm sinh viên (Dev B's feature)
    print("\n--- Tìm kiếm ---")
    search_student(students, "Van")


if __name__ == "__main__":
    main()
```

---

## Quy trình Chấm Điểm

### Các bước kiểm tra:

1. **Git config:** `git config --global user.name` + `user.email` → phải có
2. **Repo:** Kiểm tra repo trên GitHub → public, có README.md
3. **Lịch sử commit:** `git log --oneline` → ≥ 6 commits
4. **Nhánh:** `git branch -a` → có main, develop, feature/*
5. **Pull Request:** GitHub → Pull requests tab → 2 PR merged
6. **Code Review:** Có ít nhất 1 comment review trong PR
7. **Conflict:** Có bằng chứng merge conflict đã được giải quyết
8. **Chạy code:** `python src/main.py` → output đúng

---

## Các Lỗi Sinh viên Thường Gặp

| # | Lỗi | Nguyên nhân | Cách hướng dẫn |
|---|------|------------|----------------|
| 1 | Không push được: `Permission denied` | Dùng password GitHub thay vì Token | Nhắc SV tạo Personal Access Token |
| 2 | `fatal: not a git repository` | Chạy lệnh git ngoài thư mục repo | `cd devops-lab5-student-manager` |
| 3 | `src/main.py` không chạy vì import lỗi | Đứng sai thư mục khi chạy Python | Chạy từ thư mục gốc của repo |
| 4 | Merge conflict không biết sửa | Không hiểu `<<<<<<<` syntax | Giải thích: HEAD = code hiện tại, sau `====` = code từ branch |
| 5 | Push thẳng lên main thay vì tạo branch | Không làm theo Git Flow | Nhắc: git checkout -b feature/xxx trước khi code |
| 6 | Quên `git add` trước `git commit` | Bỏ qua staging area | Nhắc: git add . → git status → git commit |
| 7 | Merge PR khi chưa có review | Không đợi teammate approve | Yêu cầu: phải có ít nhất 1 review approve |
| 8 | 2 SV dùng chung 1 máy thay vì 2 máy riêng | Không mô phỏng được remote workflow | Cho 2 SV ngồi 2 máy khác nhau |
| 9 | Token bị lộ trong code/log | Copy token vào file code | Cảnh báo: token = password, không được share |
| 10 | Conflict `README.md` không detected | Cả 2 sửa khác dòng → auto-merge | Cố ý cho 2 SV sửa CÙNG 1 DÒNG |

---

## Câu hỏi Vấn đáp

1. **"Git Flow có những nhánh chính nào? Vai trò từng nhánh?"**
   → `main` (production), `develop` (tích hợp), `feature/*` (tính năng mới), `release/*` (chuẩn bị release), `hotfix/*` (sửa lỗi khẩn).

2. **"Sự khác biệt giữa `git merge` và `git rebase`?"**
   → `merge` tạo merge commit, giữ nguyên lịch sử. `rebase` viết lại lịch sử thành 1 đường thẳng, sạch hơn nhưng nguy hiểm nếu đã push.

3. **"Tại sao phải Code Review trước khi merge?"**
   → Phát hiện bug sớm, chia sẻ kiến thức trong team, đảm bảo chuẩn code, giảm technical debt.

4. **"`.gitignore` dùng để làm gì? File nào nên bỏ qua?"**
   → Bỏ qua file không cần version control: build artifacts (`__pycache__/`, `*.pyc`), config secrets (`.env`), OS files (`.DS_Store`, `Thumbs.db`), IDE config (`.vscode/`).

5. **"Khi gặp merge conflict, quy trình giải quyết là gì?"**
   → (1) Mở file bị conflict, (2) Tìm marker `<<<<<<<`, `=======`, `>>>>>>>`, (3) Chọn code giữ lại hoặc kết hợp cả 2, (4) Xóa markers, (5) `git add` + `git commit`.

---

## Tiêu chí Chấm điểm Chi tiết

| Tiêu chí | Điểm | Cách chấm cụ thể |
|----------|:----:|------------------|
| Git config | 10 | `git config --list` thấy user.name + user.email |
| Repo + Remote | 10 | `git remote -v` thấy origin, repo public trên GitHub |
| Git Cơ bản | 20 | `git log` ≥ 6 commits với message rõ ràng |
| Git Flow | 20 | `git branch -a` có main, develop, ≥ 2 feature branches |
| PR + Review | 20 | GitHub có 2 PR merged + ít nhất 1 review comment |
| Merge Conflict | 10 | Có commit merge conflict resolution |
| Sản phẩm chạy | 10 | `python src/main.py` output đúng 4 sinh viên + search |
| **TỔNG** | **100** | |

### Xếp loại:
- **Giỏi (≥85):** Hoàn thành đủ + bài tập mở rộng (Git Hooks / Conventional Commits)
- **Khá (70-84):** Đủ bước, Git Flow đúng, PR merged, code chạy
- **TB (50-69):** Cơ bản đúng nhưng thiếu PR/review hoặc conflict
- **Yếu (<50):** Chưa push được lên GitHub, chưa tạo branch
