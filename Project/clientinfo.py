# Holds all info needed for each Client so they may be neatly stored in a list
# Idea taken from my CS118 Project 2 that I am finishing as well
class Client:
    def __init__(self, id, loc, tim):
        self.id = id
        self.clock = tim
        self.loc = loc
        #ISO6709 location for lat and long
        state = 0
        sign = 1
        lat = ""
        lon = ""
        for i in range(0, len(loc)):
            if (state == 0):
                if (loc[i] == '-'):
                    sign = -1
                else:
                    sign = 1
                state = 1
            elif (state == 1):
                if (loc[i] != '+' and loc[i] != '-'):
                    lat = lat + loc[i]
                else:
                    state = 2
                    lat = float(lat)
                    self.lat = lat * sign
                    if (loc[i] == '+'):
                        sign = 1
                    else:
                        sign = -1
            else:
                lon = lon + loc[i]
        lon = float(lon)
        self.lon = lon * sign