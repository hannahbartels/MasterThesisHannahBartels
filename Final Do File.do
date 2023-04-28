*DO-file Master Thesis Hannah Bartels 

*This Do File executes all necessary steps for the hypotheses analysis, as well as Post Hoc analysis, of this research paper. However, note that for hypotheses 1A and 1B, the dataset is different than for the analysis of hypothesis 2 because this uses eye-tracking and for that analysis, 17 observations were dropped. Also, for the descriptive statistics, a different dataset is used. Therefore, we import different datasets throughout the do-file. 

import excel "E:\Scriptie\HAND IN\Final Descriptives (60 lines).xlsx", sheet("Descriptives") cellrange(A1:J61) firstrow

*6.1. Descriptive Statistics 
*First, I want to generate descriptive statistics about the variables education, age, gender, job experience and familiarity with B2B events.

tab Education
tab Age
tab Gender
tab JobExperience 
tab Familiarity

*The descriptive statistics for the eye tracking are generated with a different dataset, so we import the right dataset now. 

clear all 
import excel "E:\Scriptie\HAND IN\Final Eye tracking + Answers (223 lines).xlsx", sheet("Sheet1") cellrange(A1:AI224) firstrow

*To create Table 6, we use the comment:
tab PersuasivePoster UncertaintyLow

*Now, I want to generate the descriptives that can be found in Table 7
tabstat ViewingTime NOFTotal NOFText NOFPicture GDTotal GDText GDPicture AFDTotal AFDText AFDPicture, stats (n mean median sd min max)

*To perform the t-test to compare the gaze duration on text and picture (Appendix C.1.2.2.)
ttest GDText == GDPicture

*The paper also describes the AttentionIndex variables, so with these commands, we generate the standardized variables and generate the AttentionIndex, followed by the histogram (Figure 3) and descriptives about these variables (Table 8)

egen z1ViewingTime = std(ViewingTime)
egen z2NOFTotal = std(NOFTotal)
egen z3GDTotal = std(GDTotal)
egen z4AFDTotal = std(AFDTotal)
generate AttentionIndex = z1ViewingTime + z2NOFTotal + z3GDTotal + z4AFDTotal

hist AttentionIndex, freq normal

tabstat AttentionIndex z1ViewingTime z2NOFTotal z3GDTotal z4AFDTotal, stats (n median min max)


*6.2. Manipulation Checks 
*For this part, we import a new excel document, with 240 observations and no eye tracking data yet. 

clear all
import excel "E:\Scriptie\HAND IN\Final Answers (240 lines).xlsx", sheet("Sheet1") firstrow

*The tables in part 6.2 (Tables 9 and 10) are a summary of the t-test output, and the complete output can be found in Appendix C.2

ttest ManipulationPoster, by(PersuasivePoster)
ttest ManipulationUncertainty, by(UncertaintyLow)


*6.3. Control Variables
*In this section, I refer to Appendix C.3. for the correlation tests, that I generated with the following commands:
correlate JobExperience Familiarity
correlate Age Familiarity
correlate Age Intention
correlate Age Education
correlate Age JobExperience
correlate Intention Familiarity
correlate JobExperience Intention
correlate Education Intention
correlate Gender Intention

*To generate Table 11 (Cramer V test). To avoid the dummy variable trap, we generate four dummies for all different event types:
tab Event Intention, V
generate EventConference = 0 
replace EventConference = 1 if EventLabel=="Conference"
generate EventProductLaunch = 0
replace EventProductLaunch = 1 if EventLabel=="Product Launch"
generate EventWorkshop = 0
replace EventWorkshop = 1 if EventLabel=="Workshop"
generate EventFestival = 0
replace EventFestival = 1 if EventLabel=="Festival"


*6.4. Hypotheses 1A and 1B 
*These hypotheses test the moderating relationship betweem the type of poster and the level of uncertainty. Therefore, we first create an interaction term:
generate PersuasivePoster_UncertaintyLow = PersuasivePoster*UncertaintyLow

*To perform the linear regression defined, and generate the output from Table 12:
regress Intention PersuasivePoster PersuasivePoster_UncertaintyLow UncertaintyLow Age EventConference EventProductLaunch EventWorkshop, robust

*In the text, I refer to a Mixed Model with random intercept. The results can be found in Appendix C.4. and the model is generated by: 

mixed Intention PersuasivePoster PersuasivePoster_UncertaintyLow UncertaintyLow Age EventConference EventProductLaunch EventWorkshop || Subject: 


*6.5. Hypothesis 2
*Because we use the eye tracking data in this section, we will import a new dataset, which consists of 223 observations. It is the same dataset that we used for the descriptive statistics of the eye tracking. After importing, the same commands are repeated to generate the AttentionIndex Score by standardizing the variables for eye tracking, and to generate the interaction term between poster and uncertainty, as well as the dummy variables for the event types. 

clear all
import excel "E:\Scriptie\HAND IN\Final Eye tracking + Answers (223 lines).xlsx", sheet("Sheet1") cellrange(A1:AI224) firstrow
egen z1ViewingTime = std(ViewingTime)
egen z2NOFTotal = std(NOFTotal)
egen z3GDTotal = std(GDTotal)
egen z4AFDTotal = std(AFDTotal)
generate AttentionIndex = z1ViewingTime + z2NOFTotal + z3GDTotal + z4AFDTotal
generate PersuasivePoster_UncertaintyLow = PersuasivePoster*UncertaintyLow
generate EventConference = 0 
replace EventConference = 1 if EventLabel=="Conference"
generate EventProductLaunch = 0
replace EventProductLaunch = 1 if EventLabel=="Product Launch"
generate EventWorkshop = 0
replace EventWorkshop = 1 if EventLabel=="Workshop"
generate EventFestival = 0
replace EventFestival = 1 if EventLabel=="Festival"

*For the analysis of hypothesis 2, we will do a mediation analysis with the command sgmediation. In order to do so, we first need to install the program in STATA. This  program, which is an updated version of the previous program (now sgmediation2) is downloaded and installed via the following link:

net install sgmediation2, from("https://tdmize.github.io/data/sgmediation2")

sgmediation2 Intention, iv(PersuasivePoster) mv(AttentionIndex) cv(Age EventConference EventProductLaunch EventWorkshop UncertaintyLow PersuasivePoster_UncertaintyLow)
bootstrap r(ind_eff) r(dir_eff) r(tot_eff), reps(1000): sgmediation2 Intention, iv(PersuasivePoster) mv(AttentionIndex) cv(Age EventConference EventProductLaunch EventWorkshop UncertaintyLow PersuasivePoster_UncertaintyLow)
estat bootstrap, bc percentile


*7. Post-Hoc Analysis 
*7.1. Attention as a moderator
*To tes for the moderating role of attention on the relationship between type of poster and customer intentions, we first create an interaction term between the attention index and the type of poster, and then we perform a linear regression with the same control variables as the analysis of hypotheses 1A and 1B.

generate PersuasivePoster_AttentionIndex = PersuasivePoster*AttentionIndex
regress Intention PersuasivePoster AttentionIndex PersuasivePoster_AttentionIndex UncertaintyLow PersuasivePoster_UncertaintyLow Age EventConference EventProductLaunch EventWorkshop, robust 

*7.2. Attention to different elements
*To generate table 16, we perform 3 paired t-tests to test the differences between the picture and text AOI in number of fixations, gaze duration and average fixation duration.
ttest NOFText == NOFPicture
ttest GDText == GDPicture
ttest AFDText == AFDPicture


*Appendix E 
*E.1 Stated versus Actual Attention
*The varibable AttentionStated4 is already included in the Excel Data File. To generate the four variables to form the AttentionIndex4, as well as generate the AttentionIndex4, the following commands are used:

sum ViewingTime, meanonly
generate ViewingTime4 =4*(ViewingTime - `r(min)')/(`r(max)'-`r(min)')
sum NOFTotal, meanonly
generate NOFTotal4 =4*(NOFTotal - `r(min)')/(`r(max)'-`r(min)')
sum GDTotal, meanonly
generate GDTotal4 =4*(GDTotal - `r(min)')/(`r(max)'-`r(min)')
sum AFDTotal, meanonly
generate AFDTotal4 =4*(AFDTotal - `r(min)')/(`r(max)'-`r(min)')

generate AttentionIndex4 = (ViewingTime4 + NOFTotal4 + GDTotal4 + AFDTotal4) / 4

*To generate the descriptive statistics for the variables AttentionStated4 and AttentionIndex4, as well as the output of the ttest:
tabstat AttentionStated4 AttentionIndex4, stats (n mean median sd min max)
ttest AttentionStated4 == AttentionIndex4


*E.2. Stated versus Actual Attention per element 
*The variable AttentionStatedElement is already included in the Excel Data File. In order to rescale the variables gaze duration, number of fixations and average fixation duration per AOI, on a 0 - 1 scale, we do:
sum NOFText, meanonly
generate NOFText1 =1*(NOFText - `r(min)')/(`r(max)'-`r(min)')
sum GDText, meanonly
generate GDText1 =1*(GDText - `r(min)')/(`r(max)'-`r(min)')
sum AFDText, meanonly
generate AFDText1 =1*(AFDText - `r(min)')/(`r(max)'-`r(min)')

sum NOFPicture, meanonly
generate NOFPicture1 =1*(NOFPicture - `r(min)')/(`r(max)'-`r(min)')
sum GDPicture, meanonly
generate GDPicture1 =1*(GDPicture - `r(min)')/(`r(max)'-`r(min)')
sum AFDPicture, meanonly
generate AFDPicture1 =1*(AFDPicture - `r(min)')/(`r(max)'-`r(min)')

*To generate the AttentionIndex1 per AOI, and variable AttentionActualElement, as well as the descriptives on the attention per element (stated and actual):
generate AttentionText1 = (NOFText1 + GDText1 + AFDText1) / 3
generate AttentionPicture1 = (NOFPicture1 + GDPicture1 + AFDPicture1) / 3

generate AttentionActualElement = 0 
replace AttentionActualElement = 1 if AttentionText1>AttentionPicture1

tabstat AttentionActualElement AttentionStatedElement, stats (n mean median sd min max)

*For the output of the ttest, where the actual and stated attention per element are compared, the following command is used:
ttest AttentionActualElement == AttentionStatedElement

*The only thing that not been generated yet, are the histograms that show the outliers in the dataset, and therefore we need to download another Excel File, where the outliers are still included in the dataset. After this, we use the hist command to generate two histograms that show the outliers:

clear all 
import excel "E:\Scriptie\HAND IN\Final Eye tracking + Answers (225 lines) (including outliers).xlsx", sheet("Sheet1") cellrange(A1:AI226) firstrow

hist ViewingTime, freq
hist GDTotal, freq

