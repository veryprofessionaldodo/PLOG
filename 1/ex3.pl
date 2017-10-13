writer(maias, eca).
nationality(eca, portugues).
autor(eca).
type(maias,ficcao).
type(maias,romance).
languages(portugues).
languages(ingles).

novelersCountry(X, Country):- autor(X), nationality(X, Country),
            writer(Book, X), type(Book, romance).

fiction_and_more(Writer) :- autor(Writer), writer(Book1, Writer),
                 writer(Book2, Writer), type(Book1, romance).
