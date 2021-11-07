-- 1. Display books with the minimum number of pages issued by a particular publishing house.
-- Hər Publisherin ən az səhifəli kitabını ekrana çıxarın 
SELECT Press.[Name] PressName, Books.*
FROM Press INNER JOIN Books
ON Books.Id_Press = Press.Id
WHERE Pages = (SELECT TOP(1) Pages FROM Books
WHERE Books.Id_Press = Press.Id
ORDER BY Pages)
-- Ve ya
SELECT Press.[Name] PressName, Books.*
FROM Press INNER JOIN Books
ON Books.Id_Press = Press.Id
WHERE Pages !> ALL(SELECT Pages FROM Books
WHERE Books.Id_Press = Press.Id)

-- 2. Display the names of publishers who have issued books with an average number of pages larger than 100.	
-- Publisherin ümumi çap etdiyi kitabların orta səhifəsi 100dən yuxarıdırsa, o Publisherləri ekrana çıxarın.
SELECT Press.*
FROM Press INNER JOIN Books
ON Books.Id_Press = Press.Id
GROUP BY  Press.Id, Press.[Name]
HAVING AVG(Books.Pages) > 100

-- 3. Output the total amount of pages of all the books in the library issued by the publishing houses BHV and BINOM.
-- BHV və BİNOM Publisherlərinin kitabların bütün cəmi səhifəsini ekrana çıxarın.
SELECT Press.[Name] PressName, SUM(Books.Pages) SumPages
FROM Press INNER JOIN Books
ON Books.Id_Press = Press.Id
GROUP BY Press.[Name]
HAVING Press.[Name] IN('BHV','BINOM')

-- 4. Select the names of all students who took books between January 1, 2001 and the current date.
-- Yanvarın 1-i 2001ci il və bu gün arasında kitabxanadan kitab götürən bütün tələbələrin adlarını ekrana çıxarın.
SELECT Students.FirstName, S_Cards.DateOut
FROM Students INNER JOIN S_Cards
ON S_Cards.Id_Student = Students.Id
WHERE YEAR(S_Cards.DateOut) BETWEEN 2001 AND GETDATE()

-- 5. Find all students who are currently working with the book "Windows 2000 Registry" by Olga Kokoreva.
-- Olga Kokorevanın  "Windows 2000 Registry" kitabı üzərində işləyən tələbələri tapın.
SELECT Students.*, Books.[Name] BooksName
FROM (((Authors INNER JOIN Books ON Books.Id_Author = Authors.Id)
INNER JOIN S_Cards ON S_Cards.Id_Book = Books.Id) 
INNER JOIN Students ON S_Cards.Id_Student = Students.Id)
WHERE Authors.FirstName + Authors.LastName = 'Olga Kokoreva' AND Books.[Name] = 'Windows 2000 Registry'

-- 6. Display information about authors whose average volume of books (in pages) is more than 600 pages.
-- Yazdığı bütün kitabları nəzərə aldıqda, orta səhifə sayı 600dən çox olan Yazıçılar haqqında məlumat çıxarın. 
SELECT Authors.*
FROM Books INNER JOIN Authors
ON Books.Id_Author = Authors.Id
GROUP BY Authors.Id,Authors.FirstName, Authors.LastName
HAVING AVG(Pages) > 600

-- 7. Display information about publishers, whose total number of pages of books published by them is more than 700.
-- Çap etdiyi bütün kitabların cəmi səhifə sayı 700dən çox olan Publisherlər haqqında ekrana məlumat çıxarın
SELECT Press.*, SUM(Pages) SumPages
FROM Books INNER JOIN Press
ON Books.Id_Press = Press.Id
GROUP BY Press.Id,Press.[Name]
HAVING SUM(Pages) > 700

