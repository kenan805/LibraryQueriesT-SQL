-- 8. Display all visitors to the library (and students and teachers) and the books they took.
-- Kitabxananın bütün ziyarətçilərini və onların götürdüyü kitabları çıxarın.
SELECT Teachers.Id, Teachers.FirstName + Teachers.LastName AS LibraryVisitors, Books.[Name] AS BooksName 
FROM ((Teachers INNER JOIN T_Cards ON T_Cards.Id_Teacher = Teachers.Id)
INNER JOIN Books ON T_Cards.Id_Book = Books.Id)
UNION
SELECT Students.Id, Students.FirstName + Students.LastName, Books.[Name] 
FROM ((Students INNER JOIN S_Cards ON S_Cards.Id_Student = Students.Id)
INNER JOIN Books ON S_Cards.Id_Book = Books.Id)

-- 9. Print the most popular author (s) among students and the number of books of this author taken in the library.
-- Studentlər arasında ən məşhur author(lar) və onun(ların) götürülmüş kitablarının sayını çıxarın.
SELECT TOP(1) WITH TIES Authors.FirstName + Authors.LastName AuthorsFullName, COUNT(*) Popular
FROM (((Students INNER JOIN S_Cards ON S_Cards.Id_Student = Students.Id)
INNER JOIN Books ON S_Cards.Id_Book = Books.Id)
INNER JOIN Authors ON Books.Id_Author = Authors.Id)
GROUP BY Authors.FirstName + Authors.LastName
ORDER BY Popular DESC

-- 10. Print the most popular author (s) among the teachers and the number of books of this author taken in the library.
-- Muellimler arasında ən məşhur author(lar) və onun(ların) götürülmüş kitablarının sayını çıxarın
SELECT TOP(1) WITH TIES Authors.FirstName + Authors.LastName AuthorsFullName, COUNT(*) Popular
FROM (((Teachers INNER JOIN T_Cards ON T_Cards.Id_Teacher = Teachers.Id)
INNER JOIN Books ON T_Cards.Id_Book = Books.Id)
INNER JOIN Authors ON Books.Id_Author = Authors.Id)
GROUP BY Authors.FirstName + Authors.LastName
ORDER BY Popular DESC

-- 11. To deduce the most popular subjects (and) among students and teachers.
--  Student və Teacherlər arasında ən məşhur mövzunu(ları) çıxarın.
SELECT TOP 1 Books.Name PopularThemesStudents, (SELECT TOP 1 Books.Name
FROM (T_Cards INNER JOIN Books ON T_Cards.Id_Book = Books.Id)
INNER JOIN Themes ON Books.Id_Themes = Themes.Id
GROUP BY Books.Name               
ORDER BY COUNT(*) DESC) PopularThemesTeachers
FROM (S_Cards INNER JOIN Books ON S_Cards.Id_Book = Books.Id)
INNER JOIN Themes ON Books.Id_Themes = Themes.Id
GROUP BY Books.Name               
ORDER BY COUNT(*) DESC

-- 12. Display the number of teachers and students who visited the library.
-- Kitabxanaya neçə tələbə və neçə müəllim gəldiyini ekrana çıxarın.
SELECT COUNT(*) AS TeachersCount, (SELECT COUNT(*)
FROM Students INNER JOIN S_Cards ON S_Cards.Id_Student = Students.Id) AS StudentsCount
FROM Teachers INNER JOIN T_Cards ON T_Cards.Id_Teacher = Teachers.Id

-- 13. If you count the total number of books in the library for 100%, then you need to calculate how many books (in percentage terms) each faculty took.
-- Əgər bütün kitabların sayını 100% qəbul etsək, siz hər fakultənin neçə faiz kitab götürdüyünü hesablamalısınız.
DECLARE @AllCountBooks int = (SELECT COUNT(*) FROM Books)
SELECT Faculties.Name , CAST(CAST(COUNT(*) AS float) / @AllCountBooks * 100 AS nvarchar(MAX)) + ' %' PercentBooks FROM ((((Books INNER JOIN S_Cards ON S_Cards.Id_Book = Books.Id)
INNER JOIN Students ON S_Cards.Id_Student = Students.Id)
INNER JOIN Groups ON Students.Id_Group = Groups.Id)
INNER JOIN Faculties ON Groups.Id_Faculty = Faculties.Id)
GROUP BY Faculties.Name

-- 14. Display the most reading faculty and the most reading chair.
-- Ən çox oxuyan fakultə və dekanatlığı ekrana çıxarın
SELECT TOP 1 Faculties.Name MostFacultyName, (SELECT TOP 1 Departments.Name
FROM Departments INNER JOIN Teachers
ON Teachers.Id_Dep = Departments.Id
GROUP BY Departments.Name
ORDER BY COUNT(*) DESC) MostDepartmentName
FROM ((Faculties INNER JOIN Groups ON Groups.Id_Faculty = Faculties.Id)
INNER JOIN Students ON Students.Id_Group = Groups.Id)
GROUP BY Faculties.Name
ORDER BY COUNT(*) DESC

-- 15. Show the author (s) of the most popular books among teachers and students.
-- Tələbələr və müəllimlər arasında ən məşhur authoru çıxarın.
SELECT TOP 1 Authors.FirstName + Authors.LastName MostAtStudentsAuthorsFullName, (SELECT TOP 1 Authors.FirstName + Authors.LastName
FROM ((Authors INNER JOIN Books ON Books.Id_Author = Authors.Id)
INNER JOIN T_Cards ON T_Cards.Id_Book = Books.Id)
GROUP BY Authors.FirstName + Authors.LastName
ORDER BY COUNT(*) DESC) MostAtTeachersAuthorsFullName
FROM ((Authors INNER JOIN Books ON Books.Id_Author = Authors.Id)
INNER JOIN S_Cards ON S_Cards.Id_Book = Books.Id)
GROUP BY Authors.FirstName + Authors.LastName
ORDER BY COUNT(*) DESC

-- 16. Display the names of the most popular books among teachers and students.
-- Müəllim və Tələbələr arasında ən məşhur kitabların adlarını çıxarın.
SELECT TOP 1 WITH TIES Books.[Name]
FROM ((((Students INNER JOIN S_Cards ON S_Cards.Id_Student = Students.Id)
INNER JOIN Books ON S_Cards.Id_Book = Books.Id)
INNER JOIN T_Cards ON T_Cards.Id_Book = Books.Id)
INNER JOIN Teachers ON T_Cards.Id_Teacher = Teachers.Id)
GROUP BY Books.[Name]
ORDER BY COUNT(*) DESC

-- 17. Show all students and teachers of designers.
-- Dizayn sahəsində olan bütün tələbə və müəllimləri ekrana çıxarın.
SELECT Teachers.Id, Teachers.FirstName + Teachers.LastName AS TeachersStudentsInfo FROM Teachers
WHERE EXISTS(SELECT * FROM Departments
WHERE Teachers.Id_Dep = Departments.Id AND Departments.Id = 2)
UNION
SELECT Students.Id, Students.FirstName + Students.LastName
FROM ((Students INNER JOIN Groups ON Students.Id_Group = Groups.Id)
INNER JOIN Faculties ON Groups.Id_Faculty = Faculties.Id)
WHERE Faculties.Id = 2

-- 18. Show all information about students and teachers who have taken books.
-- Kitab götürən tələbə və müəllimlər haqqında informasiya çıxarın.
SELECT Teachers.Id, Teachers.FirstName + Teachers.LastName AS LibraryVisitors
FROM ((Teachers INNER JOIN T_Cards ON T_Cards.Id_Teacher = Teachers.Id)
INNER JOIN Books ON T_Cards.Id_Book = Books.Id)
UNION
SELECT Students.Id, Students.FirstName + Students.LastName
FROM ((Students INNER JOIN S_Cards ON S_Cards.Id_Student = Students.Id)
INNER JOIN Books ON S_Cards.Id_Book = Books.Id)

-- 19. Show books that were taken by both teachers and students.
-- Müəllim və şagirdlərin cəmi neçə kitab götürdüyünü ekrana çıxarın.
SELECT COUNT(Teachers.Id) + (SELECT COUNT(Students.Id) AS StudentsCount
FROM ((Students INNER JOIN S_Cards ON S_Cards.Id_Student = Students.Id)
INNER JOIN Books ON S_Cards.Id_Book = Books.Id)) BooksCount
FROM ((Teachers INNER JOIN T_Cards ON T_Cards.Id_Teacher = Teachers.Id)
INNER JOIN Books ON T_Cards.Id_Book = Books.Id)

-- 20. Show how many books each librarian issued.
-- Hər kitabxanaçının (libs) neçə kitab verdiyini ekrana çıxarın
SELECT Libs.FirstName + Libs.LastName LibsFullName, 
((SELECT COUNT(*)
FROM S_Cards
WHERE S_Cards.Id_Lib = Libs.Id
GROUP BY S_Cards.Id_Lib) +
(SELECT COUNT(*)
FROM T_Cards
WHERE T_Cards.Id_Lib = Libs.Id
GROUP BY T_Cards.Id_Lib)) AS Total
FROM Libs



