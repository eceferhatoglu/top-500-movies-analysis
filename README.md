# Top Movies Dataset SQL Project

## Introduction
This project uses SQL to explore a curated dataset of top-rated movies, looking at how scores, genres, popularity, and critic/audience perception relate to each other.

The analysis builds a chain of targeted questions to challenge initial assumptions: Do critics and audiences actually agree? Is Drama really a better genre, or does it just skew older? Is a movie's vote count a signal of quality, or a completely separate phenomenon?

📁 **Quick Links:**
* **Source Dataset:** [Kaggle - Top 500 Movies Ranked by Combined Critics & Audience Scores](https://www.kaggle.com/datasets/prashant0kumar7/top-500-movies-ranked-by-combined-critics)
* **SQL Files:** 
  * `critic_vs_audience.sql` — Audience score weighting, correlation checks, and critic-vs-audience sentiment comparisons.
  * `genre_and_temporal_trends.sql` — Top-tier film filtering, genre breakdowns, decadal shifts, and era-control testing.
  * `popularity_metrics.sql` — Combined vote metrics, volume-vs-quality analysis, and underrated films.


## Background
The analysis works through a chain of questions, each one built to test or challenge the previous finding:

* What are the top-tier movies (high scores from both audiences and critics), and which genres dominate them?
* Where do critics and audiences disagree most, and how strong is the relationship between their scores overall?
* Do certain genres (Drama, Horror, Sci-Fi, Family) score systematically higher than others — and if so, why?
* Have movie scores changed over time, and what does that actually mean for a "top-N of all time" list?
* Is Drama's score advantage a real genre effect, or an artifact of Drama-tagged films skewing older?
* Does popularity (vote volume) predict quality (score) — or are they independent?


## Tools
* **SQL**: Core language for querying, aggregation, `CASE WHEN` logic, `CORR()`, CTEs, and window-style comparisons.
* **PostgreSQL**: Database used to host and query the dataset.

## Analysis & Key Findings
### 1. Critics vs. Audiences
Building a votes-weighted audience score (blending IMDb, Letterboxd, and audience review sources) and comparing it against critic scores:
* Only two films (*The Godfather*, *Seven Samurai*) appear in both the critics' top 10 and the audience's top 10.
* Critics lean toward near-universal consensus picks (e.g. *Citizen Kane*); audiences lean toward big adventure/cultural hits (e.g. *The Lord of the Rings*).
* Critics rate higher than audiences for roughly 70% of films. The widest critic-favoring gaps are in prestige animation and classics (*Pinocchio* +21, *E.T.* +20, *Snow White* +19).
* The overall correlation between critic and audience scores is **0.12** — almost no relationship. Caveat: this is a curated top-N dataset where every film already cleared a quality bar, which restricts score range and can mechanically weaken correlation — the true relationship across all movies (not just top-rated ones) may be stronger.

### 2. Top-Tier Movies
Filtering for films where both `weighted_audience_score` and `critic_rating_rt` exceed 85:
* The list is heavily classic-era weighted — median release year 1965, only 3 films from after 2000.
* **Francis Ford Coppola** leads directors with 3 films; **Paramount Pictures** leads studios with 6.
* **Drama** dominates the genre mix (20 of 30 titles), with Crime and Thriller tied for a distant second (6 each).

### 3. Genre Breakdown (Drama, Horror, Sci-Fi, Family)
Pulling the top 10 per genre:
* **Drama scores highest** (avg 92.2, every film 91+). Horror, Sci-Fi, and Family cluster lower and close together (86.6–87.8).
* Drama and Horror both skew old (avg release year 1964 / 1961). Sci-Fi and Family skew newer (1985 / 1990) — likely because effects- and animation-driven films can compete on craft without needing decades of critical reassessment.
* Only two films cross genre lines (*Alien*, *WALL·E*) — the four genre lists are otherwise cleanly separated.

### 4. Scores Over Time
Grouping by decade:
* The 1950s is the best-performing decade; the 2000s is the lowest. Scores decline as decades progress.
* Because this is a top-N **all-time** list (not a general catalog), the best explanation is **canonization lag** — older films have had more time to build the critical/cultural consensus needed to make an all-time list, while recent films haven't had that time yet.
* Tested this against a competing "survivorship bias" theory using score variance by decade — variance is actually *lowest* in recent decades, not highest, which doesn't support survivorship. Canonization lag remains the better-supported explanation.

### 5. Is Drama's Advantage Real, or Just Age?
Comparing Drama vs. Non-Drama scores *within the same decade* isolates genre from era:
* Drama holds a real, sizeable lead pre-1960s (+1.25 to +2.4 pts every decade).
* From the 1980s onward, the gap collapses to under 1.3 pts and flips sign inconsistently — consistent with noise, not a genre effect.
* Both groups decline together across decades — confirming the era effect applies regardless of genre.
* Caveat: pre-1960s sample sizes are small (n=2–19 per group), so even the early gap isn't confirmed as statistically significant.
* A further check — critic vs. audience score gap for Drama vs. Horror — found the gap is driven *more* by audience scores than critic scores, which weakens (rather than supports) the theory that institutional/critical bias favors Drama.

### 6. Popularity vs. Quality
After building a `total_votes` column (combining critic reviews, audience reviews, Letterboxd, and IMDb votes):
* **Votes and score are not meaningfully correlated.** *Titanic* has the most votes in the dataset (27.9M) but one of the lowest scores; *Parasite* scores highest (92.0) on a fraction of the votes (6.1M).
* The most-voted films skew *newer*, the opposite direction from the score-by-decade trend — popularity and canonized quality are separate tracks.
* The "most underrated" list (high score, <200K votes) is dominated by documentaries and foreign/arthouse films — genres that rarely reach blockbuster vote counts regardless of quality.
* The full-dataset correlation between votes and score came out to **-0.097** — essentially negligible. Earlier estimates from small curated subsets (up to -0.99 for some genres) were inflated by selection bias, since those subsets were deliberately drawn from the extremes.



## Conclusions
1. **Surface-level genre rankings are misleading without controlling for era.** Drama looks like the "best" genre overall, but most of that advantage disappears once you compare films from the same decade — it's largely an artifact of Drama-tagged films skewing older in a dataset that structurally favors older films.
2. **"Best of all time" lists reward canonization, not just quality.** Older films dominate because they've had more time to build consensus — not necessarily because filmmaking quality has declined.
3. **Popularity and critical/audience quality are independent.** High vote counts don't predict high scores, and vice versa — being widely watched and being highly rated are separate phenomena in this dataset.
4. **Critics and audiences reward different things.** Their scores are only weakly correlated; critics favor consensus prestige picks, audiences favor big cultural and cult favorites.
5. **Small samples can manufacture strong-looking patterns.** Several early "clear" findings (genre correlations up to -0.99, a consistent Drama edge) weakened substantially once tested against larger, less-curated data — a reminder to sanity-check any striking result against sample size before treating it as confirmed.