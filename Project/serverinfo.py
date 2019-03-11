#Allocated port numbers: 12165-12169

api_key = "AIzaSyCBxj8iB0MwWHV6XqMo0A3sp2hrXot37j4"
url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?"

#Holds names of all valid servers
server_boiz = ["Goloman", "Hands", "Holiday", "Wilkes", "Welsh"]

#Holds which servers are connected to which
server_bonds = {
    "Goloman": ["Hands", "Holiday", "Wilkes"],
    "Hands" : ["Goloman", "Wilkes"],
    "Holiday" : ["Goloman", "Wilkes", "Welsh"],
    "Wilkes" : ["Goloman", "Hands", "Holiday"],
    "Welsh" : ["Holiday"]
}

#Holds which server corresponds to which port number
server_portnums = {
    "Goloman" : 12165,
    "Hands" : 12166,
    "Holiday" : 12167,
    "Wilkes" : 12168,
    "Welsh" : 12169
}