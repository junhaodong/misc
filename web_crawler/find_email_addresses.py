import dryscrape, re, sys
from bs4 import BeautifulSoup

class EmailCrawler:
    """
    Takes a domain name and prints out a list of email addresses found on that web page
    or a lower level web page with the same given domain name.
    Stores emails, paths, and visited_paths as sets to avoid duplicates.
    Uses Dryscrape to dynamically scrape text of JavaScript generated and static websites.
    Uses BeautifulSoup to search for valid href's to continue crawling on.
    """
    emailRE = re.compile("[\w.+-]+@(?!\dx)[\w-]+\.[\w.-]+[\w-]+")

    def __init__(self, domain):
        if 'http' not in domain:
            domain = 'http://' + domain
        self.url = domain.lower()
        self.session = dryscrape.Session(base_url=self.url)
        self.emails = set()
        self.paths = set()
        self.visited_paths = set()
        self.num_pages_limit = 50

        self.session.set_attribute('auto_load_images', False)

    def is_valid_tag(self, tag):
        """Checks if a tag contains a valid href that hasn't been visited yet."""

        if tag.has_attr('href') and len(tag['href']) > 0:
            href = tag['href']
            complete_href = self.session.complete_url(href)

            is_relative = self.url in complete_href
            is_visited = complete_href in self.visited_paths
            is_style_sheet = tag.name == "link"
            is_jumpTo = "#" in href
            is_mailTo = "mailto" in href
            is_js = "javascript:" in href
            return is_relative and \
                not (is_visited or is_style_sheet or is_jumpTo or is_mailTo or is_js)
        else:
            return False

    def find_emails_and_paths(self, path=None):
        # Load the DOM
        try:
            self.session.visit(path)
        except:
            print("Error accessing the given URL")
            return

        # Pass the DOM as HTML into the lxml parser
        print("Crawling on:\t" + path)
        response = self.session.body()
        soup = BeautifulSoup(response, "lxml")

        # Add new emails to `self.emails` 
        for email in re.findall(self.emailRE, response):
            self.emails.add(email)

        # Mark the current path as visited
        self.visited_paths.add(path)

        # Add new paths to `self.paths`
        for tag in soup.find_all(self.is_valid_tag):
            href = self.session.complete_url(tag['href']).lower()
            self.paths.add(href)

    def find(self):
        """
        Crawls through new paths until the page limit has been reached or
        there are no more discoverable paths.
        """
        self.paths.add(self.url)
        while len(self.visited_paths) < self.num_pages_limit and \
              len(self.paths) > 0:
            self.find_emails_and_paths(path=self.paths.pop())

    def print_emails(self):
        # Print the emails found (if any)
        if len(self.emails) > 0:
            print("\nFound these email addresses:")
            for email in self.emails:
                print("\t" + email)
        else:
            print("\nNo email addresses found.")

def main():
    """
    Initializes the crawler with the given domain name
    and optional maximum number of pages to search.
    Finds and prints any emails found.
    """
    if len(sys.argv) >= 2:
        crawler = EmailCrawler(sys.argv[1])
        if len(sys.argv) >= 3 and sys.argv[2].isdigit():
            crawler.num_pages_limit = int(sys.argv[2])

        print("Beginning crawl with a limit of " + str(crawler.num_pages_limit) + " pages...\n")
        crawler.find()
        crawler.print_emails()
    else:
        print("Error: Please enter a domain to search on and an optional page limit (default=50).")
        print("Example: `python find_email_addresses.py jana.com 30`")
        sys.exit(1)

if __name__ == "__main__":
    main()
