# Papers

## Shugars, "The Structure of Reasoning: Measuring Justification and Preferences in Text"

This paper tries to build theoretical and operational models of political _reasoning_ that takes place before opinions are expressed.
If $y_{i}$ is a survey response for person $i$, what is the interactive network structure among their thoughts and ideas contained in $x_{i}$?

Theoretically, we invoke a network model of political ideas and justifications.
Some ideas are connected to other ideas, and that's how conversations work.
Psych, linguistic, and philosophical takes use networks to represent memories, argumentative premises, and normative ideas like "coherence" or moral underpinnings.

Method has two main parts:

1. Word embeddings.
  Use Google News corpus to create a "grammatical parse" or each word in grammatical structure.
2. Create a network of original datasets out of the grammatical structures of each words. 
  These networks are the basis of the original data analysis.

### Word embedding

A word embedding is a word's location in a 300-D space.
Call this a word's "vector representation."
\begin{align}
  \frac{1}{T} \sum\limits_{t = 1}^{T} \sum\limits_{-c \leq j \leq c: j \neq 0}
  \log p\left(w_{t+j} \mid w_{t} \right)
\end{align}
For a sequence of training words $w_{1}, w_{2}, \ldots, w_{T}$ and a context window $c$.
In other words, a training model tries to predict word $w_{t + j}$ using word $w_{t}$, and the word vectors that are selected are the vectors that best predict each word's surrounding words. 

This is used to define which words belong to which _concepts._ "In this paper, clusters of words are taken to refer to the same concept if all words in that cluster have cosine similarity greater than 0.5."
Concepts serve then as nodes (I think).


###  Network structure

Use a "grammatical parse" to determine how nodes are connected, not just their proximity.
Grammatical connection between nodes creates edges.
All occurrences of a concept (read: word within a concept) are treated as a single node, so one node's edges contain all grammatical connections between a concept and other concepts.


### Analysis of similar networks

You can construct a graph for each individual, but there is no guarantee that they contain overlapping nodes to compare structure.

To compare two arbitrary networks, we use "portrait divergence" (Bagrow and Bollt 2019). 
Each graph (for each individual) has a "portrait" $B$, which is an asymmetric matrix.
Entry $B_{kl}$ "captures the number of nodes $k$ which have path length $l$".
From Bagrow and Bollt: $B_{kl}$ is the number of nodes who have $k$ nodes at distance $l$.
Similarity between two networks is measured as Kolmogoros-Smirnov statistic, which is the "maximum distance" between two networks.

### Analysis of dissimilar networks:

There is a suite of network connectivity measures (average degree, clustering, giant component percent, density) and network heterogeneity measures (standard deviation of degree, entropy, assortativity).
There is a helpful Table 1 that describes these.


### Original data

An MTurk survey of free-response answers, and a secondary YouGov survey by Dan Hopkins and Hans Noel of ideological "Turing test" responses. 
The ideological Turing test asks participants to argue both sides of an issue, and see if they can do it convincingly. 
Only half of participants were sincere in their participation.
Shugars interpretation is: only half are _argumentatively structured so as to be meaningful_, which we can take advantage of for analyzing the structure of reasoning.

MTurk data: network measures are correlated with personality traits and ideology.
That is, not just policy preferences, but the way those preferences are reasoned about! 
"...combination of network statistics suggests that progressive subjects tend to form networks with a core–periphery structure—that is, networks with an interconnected core of central ideas surrounded by a periphery of loosely connected auxiliary ideas."
And "Conservative subjects...produce more homogeneous networks in which each idea is roughly similarly connected, but further suggests these subjects tend to produce less content overall...We also see through the giant component metric that conservative subjects are more likely to produce networks with multiple, disconnected components while progressives are more like to produce connected networks, suggesting that a major difference in structure may be a tendency to 'bridge' between different clusters of distinct thought, with progressives more likely to tie disparate concepts together and conservatives more likely to articulate differing strains of though separately."

YouGov data: network stats predict the human-coded Turing test classification, meaning they capture the quality of reasoning. 
Shugars additionally asks if responses are driven by _content similarity_, or _individual traits_?
Meaning, is $i$'s conservative response more similar to $i$'s liberal response (individual traits drive response similarity), or more similar to $j \neq i$'s conservative response (content of response drives argumentative similarity)?
Answer: individual is closer to themselves, suggesting that network structure captures individual level patterns in reasoning and thinking, not content-driven connections.





