# network communities

Implementation of the Girvan-Newman algorithm to find network communities.

## Running the Script

Run `python3 community_detection.py`

Required dependencies:
- `pip install networkx`
  - https://networkx.github.io/documentation/stable/install.html
- `python3 -mpip install matplotlib`
  - https://matplotlib.org/faq/installing_faq.html#installation

## Output
Setting the average degree (average out-degree + average in-degree) to 16, the graph dips at `x = 8`, which is when the graph becomes homogeneous.  
<img src="https://user-images.githubusercontent.com/5431678/34019921-70a6a25e-e131-11e7-8f29-d919d7b85337.png"
	alt="Simple Tree" height="350px" />

The detected communties in our benchmark network of 4 communities, 32 nodes each.
<img src="https://user-images.githubusercontent.com/5431678/34020187-1107dea6-e133-11e7-8e31-df276c7ad94b.png"
	alt="Simple Tree" height="350px" />

The detected communties in a protein structure network.
<img src="https://user-images.githubusercontent.com/5431678/34020188-13628ac0-e133-11e7-8334-ab41c77fd7e3.png"
	alt="Simple Tree" height="350px" />
