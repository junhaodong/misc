# EmailCrawler
-------
A command line program that takes an internet domain name (i.e. "jana.com") and an optional maximum integer number of pages to search.  
Prints out a list of the email addresses found on that given domain, refraining from visiting separate domains.

![Sample code output](https://user-images.githubusercontent.com/5431678/31203602-22c794e0-a968-11e7-9fdb-a921c5638266.png)

## Requirements

Root access with `sudo` is not needed when running on a Python Virtual Environment.

[Pip](https://pip.pypa.io/en/stable/installing/)
```
> sudo easy_install pip
```

[Dryscrape](https://dryscrape.readthedocs.org/en/latest/installation.html)
```
> sudo pip install dryscrape
```

[lxml](http://lxml.de/index.html#download)
```
> sudo pip install lxml
```

[Beautiful Soup](http://www.crummy.com/software/BeautifulSoup/bs4/doc/#installing-beautiful-soup)
```
> sudo pip install beautifulsoup4
```
