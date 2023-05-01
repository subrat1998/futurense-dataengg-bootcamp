from mrjob.job import MRJob


class RatingCount(MRJob):
    def mapper(self,movieId,record):
        if record.split(',')[2][0] != 'r':
            rating=float(record.split(",")[2])
            if rating >=1 and rating <2 :
                yield("Rating 1+", 1)
            elif rating >=2 and rating<3:
                yield("Rating 2+", 1)
            elif rating >=3 and rating<4:
                yield("Rating 3+", 1)
            elif rating >=4 and rating<5:
                yield("Rating 4+", 1)
            elif rating >=5 and rating<6:
                yield("Rating 5+", 1)
            else:
                yield("Rating Below 1",1)


    def reducer(self,rating, vals):
        yield(rating,sum(vals))
        
if __name__ == '__main__':
        RatingCount.run()
