def isogram(word):
    holdme = {}
    for i in word:
        if i in holdme:
            return False
        else:
            holdme[i] = 1
    return True

def main():
    print(isogram("pepe"))
    return 
    
if __name__ == "__main__":
    main()