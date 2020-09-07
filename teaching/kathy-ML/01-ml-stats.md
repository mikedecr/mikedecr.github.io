# Statistics from the ML Point of View

"Machine learning" evolved somewhat separately in statistics as it did in computer science.
As a result, there are important differences in philosophy and in jargon that are worth establishing from the outset.
The purpose of this introduction is to lay out a broad enough view of the objectives of machine learning, discuss important differences in jargon, and draw a broad contrast between the predictive modeling workflow/philosophy and the "traditional academic statistics" workflow that we learn in political science.



## Broad contours

Personally I don't so much like the phrase "machine learning" because it is  hard to tell what counts as "statistics" and what counts as "machine learning." 
My experience with the non-academic world suggests that all statistical methods belong to a class of methods known as "machine learning,"
i.e. any method where the computer estimates patterns in data and has the capacity to predict new data.
I personally like to use the phrase _predictive models_ because it feels more closely aligned with what we're actually doing, and more broadly encompassing predictive modeling approaches from both "statistics" and "computer science."
If I refer to "machine learning" or "ML," I usually mean to distinguish the computer science methods from the more familiar statistical methods that we're used to.

Predictive models generally take the following form.
We have some $y_{i}$, an outcome measure for some unit $i$, that we want to predict using $\mathbf{x}_{i}$, a vector of covariates for unit $i$.
An equation for $y_{i}$ is given by
\begin{align}
  y_{i} &= f\left(\mathbf{x}_{i}\right) + \epsilon_{i}
  (\#eq:yfx)
\end{align}
where $\epsilon_{i}$ is an error term.
We're remaining more general than any regression setup that we're familiar with in political science or social science more broadly.
All we have is $y_{i}$ as a function of $\mathbf{x}_{i}$ plus error.
Currently we're imposing no functional form assumptions on $f(\cdot)$ and no distributional assumptions on $\epsilon_{i}$.

Predictive models/"machine learning" is nothing but a bunch of models that people design to estimate $f(\cdot)$.
Let $\hat{f}(\cdot)$ be our predictive model for $f(\cdot)$, which lets usrelate the observed $y_{i}$ to our model of choice.
\begin{align}
  y_{i} &= \hat{f}\left(\mathbf{x}_{i}\right) + e_{i}
  (\#eq:yfhatx)
\end{align}
where $e_{i}$ now represents the error in our model predictions.
\begin{align}
   e_{i} &= y_{i} - \hat{f}\left(\mathbf{x}_{i}\right)
  (\#eq:model-error)
\end{align}
How do we pick $\hat{f}(\cdot)$?
Sometimes by minimizing the error $\epsilon_{i}$, like simple OLS without distributional assumptions for the error.
Sometimes we do make statistical assumptions about $\epsilon_{i}$ and then optimize a function of $\epsilon_{i}$ subject to the constrains of those assumptions, like with maximum likelihood.
Because predictive methods are also used in industry settings, some methods work by assigning dollar values to the $\epsilon_{i}$ and optimizing a dollar-weighted error.
This latter estimation objective introduces the notion of "loss," which you can think about as a generalization of the notion of error.
"Loss" is essentially a cost function of model inaccuracy: inaccurate predictions are mad, they lose money, and so the preferred model is the one that minimizes money lost. 
As a result, optimizing model _accuracy_ on its own won't be the best way to diagnose diseases if misdiagnosis in one direction is more costly than in the other direction.



### Mapping between jargons

**Bold** is ML jargon, and the rest is translation.

- **Target.** The dependent variable.
  The thing we're trying to predict.
- **Label.** the dependent variable value.
  If I have "labeled data," it means I know the target value for those observations. These are the observations often used to "train" a model especially in text settings.
- **Features.** Independent variables/covariates.
  Characteristics of units that inform us about the "target."
- **Objective function.** The function we want to optimize in order to fit a model or make predictions.
  This could be residual sum of squares, a likelihood function, a posterior density, dollar-weighted combinations of any of these...
- **Loss function.** An objective function construed in terms of "loss."
  For objective functions that we want to maximize (likelihood functions, posterior densities...) the loss function can just be a sign-flipped version of the objective function.
- **Class.** "Levels" of a discrete outcome variable.
  As in, we have an outcome variable with $K$ possible classes, each indexed $k$. 
  For a binary outcome, $K = 2$ and $k \in \{1, 2\}$. 
  More generally, $k \in \{1, 2, \ldots, K \}$.
- **Classification.** Predicting a class for a unit. 
  Ordinarily we estimate probabilities in social science, but classification goes one step farther to make a decision about predicted "class membership" for each unit.
  This extra step usually requires a decision rule that maps predicted probabilities to predicted classes.
  ML theory considers optimal models for generating predicted probabilities as well as optimal decision rules (optimal in terms of loss).
  For instance, logit or multinomial logit estimate the probabilities of class membership, but K-nearest-neighbor classification simply says that the predicted class for unit $i$ is the modal class among the neighboring observations, which entails a decision rule.
- **Inference.** This one bugs me to no end.
  In statistics, "inference" refers to decision-making about estimates under uncertainty, i.e. what are the statistical properties of my estimator and how do I leverage those properties to make decisions about my model. 
  In machine learning, inference usually just means "prediction."
  Once I fit a model, making a prediction for a new data point is "inference" about $y_i$ given $\mathbf{x}_{i}$.
  This makes a little more sense if you mentally imagine a Bayesian analogy.
  I have updated beliefs about $y_{i} \mid \mathbf{x}_{i}$, so prediction is like "posterior inference."
  But, unaccountably, ML uses this language with no homage to Bayesian inference in particular, and in general any statistical consciousness at all is not strictly necessary.
- **Training.** Model fitting. 
  "Training a model" means fitting it to data. 
  The significance of "training" as opposed to "fitting" is usually that we have no interest in making predictions for model used to "fit" the data, so the quality of model "fit" for in-sample data is not an ingredient for marginal decision-making most of the time.
  Instead, the whole point of "training" is for the model to make predictions elsewhere.
- **Learner.** Infuriatingly, this just means "model."
  Sometimes the "learner" jargin comes in handy for some models that are actually compositions/ensembles of other models, or compositions of many low-weight predictions.
  For instance, tree models (BART, random forests, etc.) generate a prediction as the sum or average of all of the predictions from many decision trees. 
  Each individual tree is sometimes called a "weak learner," since an individual tree isn't very good, but aggregating over trees is better.
- **Training set/training data.** The data used for fitting a model.
- **Test data/test set**. 
  Held-out data for measurement a model's out-of-sample predictive performance.
  Typically the researcher considers many model configurations, and the chosen model configuration is the one that minimizes out-of-sample predictive loss (or maximizes out-of-sample "value" however measures).
  You have to give props to ML over academic stats here because the predictive performance of the model _actually matters for decision-making_, unlike in traditional academic stats where performance is almost never a concern, or if it is, it is measured in-sample and thus is prone to overfitting.
- **Supervised learning.** 
  Fitting a model to data with known $y$ and known $\mathbf{x}$. 
  "Supervised" only means that for the data being used to fit the model, we know the correct left-hand data.
- **Unsupervised learning.**
  Looking for patterns where there is no perfect analogy to $y$. 
  This most typically includes dimensional reduction, where I have data of some unknown high dimensionality that I'm trying to simplify into fewer dimensions.
  The reduced space could be made of discrete clusters of observations, low-dimensional summaries of high dimensional data (e.g. "principal components", latent factors, etc.).
  My soap-box is that this isn't "unsupervised" at all, it's just a model for a process that makes $\mathbf{x}$ instead of modeling the process that makes $y$. 
  Any model of latent structure probably fits in here, especially models where we have to discover the latent structure.
  In PS context this includes ideal point models, models for "democracy as a latent variable." 
  It is also where we will probably spend most of our time when it comes to topic models (cluster assignments for text), sentiment analysis (factor analysis for text), since the text itself is being modeled for its underlying structure.




### Predictive accuracy/error

Because most ML methods make predictive accuracy a preeminent goal, being explicit about the measure of predictive accuracy is essential.
In a standard continuous outcome setting, this measure is often mean square error,
\begin{align}
  \mathit{MSE} &= \frac{1}{n} \left(y_{i} - \hat{y}_{i} \right)^{2}
  (\#eq:mse)
\end{align}
where $\hat{y}_{i} = \hat{f}\left(\mathbf{x}_{i}\right)$. 
Sometimes this is discussed in terms of root mean square error, $\mathit{RMSE} = \sqrt{\mathit{MSE}}$.
Reminder, MSE can be decomposed as the sum of of bias and variance. 
As long as either term is nonzero, MSE is nonzero:
\begin{align}
  \mathit{MSE} &= \mathit{Bias}\left(\hat{y}_{i}\right)^2 + \mathit{Var}\left(\hat{y}_{i}\right)
  (\#eq:mse-decomp)
\end{align}
where $\mathit{Bias}(y_{i}) = E\left[y_{i} - E\left[\hat{y}_{i}\right]\right]$.
This is helpful to remember when people explain the benefits of one model over another in terms of which model settings move us which direction along the bias–variance trade-off.



### Overfitting

As stated before, ML methods consist of any method for functionally predicting $y$ using $\mathit{x}$, and the predictive accuracy of that function is crucial.
This is different from standard academic approaches, where our most important modeling goal^[
  After getting those sweet, sweet significance stars and getting published.
]
is to _interpret_ the prediction function even if other prediction functions out there would give better predictions. 
We might say that the standard social science workflow does not usually have much incentive to improve predictive accuracy (for _most_ problems, measurement being an important exception).
A natural consequence is that the typical modeling workflow does not contain tools or routines for controlling overfitting as a standard matter of course.
In the ML workflow, however, it is impossible to conceive of model-building without dedicating major effort to preventing overfitting, because the primary decision margin for evaluating a model is its predictive performance _out of sample_, i.e. on data that the model has not seen before.

All the same, the "social science statistical workflow" is at least _aware_ of the potential problems with prediction.
If we include too many meaningless predictors in a regression, we will improve the predictive accuracy of the model (e.g. increasing $R^{2}$) by fitting noise instead of actually-existing predictive signals in the data.
The sections that follow discuss how to prevent overfitting in a general ML workflow.
How these routines get implemented will naturally vary by the model type.



### Sample splitting

A crucial distinction in ML is the "training" vs. "test" data. 
AKA in-sample data vs. out-of-sample data.
The main idea is that a complex model with lots of predictive flexibility can do a great job fitting in-sample data.
More and more complex models can only ever do better predicting in-sample data.
But that doesn't make a model good.
Models are well designed when they do a good job predicting out-of-sample data, or data that the model has never seen before.

The ML workflow traditionally proceeds by taking any dataset and splitting it into a "training set" and "test set."
We fit a model on the training set, and generate predictions for the test set. 
As expected, our MSE will be higher in the training set, since those observations were used to fit the model, and MSE will be lower in the test set.
We know that we are designing the best model not when its in-sample MSE is smallest, but when its out-of-sample MSE is smallest.

Stated more succinctly, in the ML point of view, there is no point to a more complex model if it can't predict _unseen data_ better than a simpler model.
The whole purpose for the model to exist is to predict unseen, out-of-sample data.


### Regularization

$\DeclareMathOperator*{\argmin}{arg\,min}$

How does a model increase out of sample performance?
The main thing we want to do is _regularize_ a model, or constrain its solutions to prevent overfitting.

Standard models estimated in political science tend to be of an OLS or MLE framework.
The OLS solution is
\begin{align}
  \hat{\beta} &= \argmin_{\beta} \quad (\mathbf{y} - X\beta)^{\intercal}(\mathbf{y} - X\beta)
  (\#eq:ols)
\end{align}
or, "find the $\beta$ values that would minimize the residual sum of squares."
This solution is unbiased (given the true model), but for overly complex models, predictions for new data are likely to have higher MSE than a model whose estimation is penalized in some way. 

_Regularization_ is any method that penalizes the algorithm that fits a model.
In the OLS case, one example is a "ridge regression estimator," which penalizes the optimization problem by a factor of the overall coefficient magnitude.
\begin{align}
  \hat{\beta} &= \argmin_{\beta} \quad (\mathbf{y} - X\beta)^{\intercal}(\mathbf{y} - X\beta) + \lambda \sum_p \beta_p
  (\#eq:ridge) 
\end{align} 
where $\lambda$ is a penalty parameter that controls the amount of regularization.
At $\lambda = 0$, the optimization problem simply is OLS.
For larger $\lambda$ values, coefficients are shrunk toward zero, which introduces bias but tends to make more accurate predictions out-of-sample.

As a religious Bayesian, I like to think about regularization as different methods for placing priors on model parameters.
In fact, the ridge penalty is actually equivalent to giving the coefficients a Normal prior.
This is an important connection to make because text models often use Bayesian estimation approaches due to the large number of parameters in a given model.

Other models regularize in different ways.
Tree models are biased toward "shorter trees." 
Neural networks may "drop out" entire "nodes" to "simplify the signal" that passes through the network (zeroing out coefficients in a chain of regressions).


### Tuning a model with cross-validation

Once we introduce regularization into a model fitting/training problem, the researcher faces a choice of how much to regularize.
For the ridge example, it isn't obvious which value of $\lambda$ should be chosen (analogously, how tight the Normal prior should be on the coefficients).
For tree models, we have choices to make about how short to keep the trees.
These knobs are usually known as "hyperparameters" (parameters that control parameter estimation) or in a Bayesian context,
\begin{align}
  \beta &\sim \mathrm{Normal}(0, \gamma)
\end{align}
the hyperparameter $\gamma$ controls the amount of regularization. 
How do we choose which hyperparameters are best to prevent overfitting?

The most common way to do this is to use _cross-validation_, which is an iterative sample splitting technique.
Just as we split the sample above to train and test a model, cross-validation proceeds by chopping the data into many smaller pieces, testing hyperparameter values in each slice, and seeing which hyperparameters lead to optimal out-of-sample prediction. 
The way this usually goes is that there is an "initial split" to divide data into training and testing sets.
After the initial split, the training data is divided into $K$ many "folds," where a model with a certain hyperparameter configuration is trained on $K-1$ folds and then tested on fold $K$.
The $K$ folds are used to select hyperparameter settings, and then the final test set is used to test the model that is most preferred by the cross validation routine.


### Workflow Recap

The model-training workflow, as a result, usually follows a pattern like

1. initial split
2. cross-validation of hyperparameters in training set
3. choose best model from cross-validation
4. test CV-chosen model on out-of-sample data
5. repeat for other settings 

Typically you want to optimize the predictive error in step 4. 


## Broad takeaways for academic statistics


Predictive modeling contrasts with the traditional academic workflow, even though it is useful for academics.

- In "academic stats," we fit a model to all data and then make in-sample predictions. For flexible predictive models, this is a huge no-no.
- Even in academic stats, we try to generalize from data to something not in the data. 
  So I think it _does_ make sense to take a predictive modeling approach and develop a model for optimal out-of-sample prediction, since whatever "general reality" we're trying to describe is not fully contained in the sample (most of the time). 
  I think academics actually would agree with that, but they don't typically do any of the model validation work.

Why point this out?
Because text papers WILL include model validation descriptions, and this will make it easier to understand why.
Your methods classes probably described OLS and other estimates in terms of the "true model."
In the industry predictive modeling world, there isn't usually any such thing. 
In the academic predictive modeling world, there is probably some hybrid that different papers will try to nail, but I don't know if there's any way to describe this trade-off perfectly.

