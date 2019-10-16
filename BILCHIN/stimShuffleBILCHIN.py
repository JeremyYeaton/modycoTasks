# Script to shuffle auditory and visual stimuli
# Experiment: Chinese bilingual word processing (BILCHIN)
# (c) Jeremy D. Yeaton
# Created April 2019

import os, csv, random, sys

# os.chdir('/Users/yaruwu/MEGA/_PojetEEG/1_Stimuli')
# os.chdir('F:\\BILCHIN\\pyPourEEG_read')

#%%
catLabels = ["SpoA","SpoB","sPo","spO","spoA","spoB"]
#conditionNb: 	1,		1,	2,		3,		4,	4
# subNum = int(input("Subject number: "))
subNum = int(sys.argv[1])

nLists = 3
maxRep = 3 # Maximum number of the same response allowed in a row

# #### CHOOSE FROM DIFFERNT CONDITIONS

# Assign response category to alternate every 2 participants
if subNum % 2 == 0:  # ex. sujet 1,sujet 4
	responses = ['f','j'] # notlinked, linked
else: # ex. sujet 2,sujet 3
	responses = ['j','f'] # notlinked, linked
# Open practice stim file
f = open('stim\\practiceMaster.txt','r')
g = csv.reader(f,delimiter = '\t')
# h = open('SWOPstims/stimTextFiles/practiceBlock.txt','w')
h = open('stim\\practice.txt','w')
for line in g:
    #if line[-1] == '0': # Condition column: 0 = notLinked ; 1  = linked
    #    line[-1] = responses[0]
    #elif line[-1] == '1':
    #    line[-1] = responses[1]
    txtLine = '\t'.join(line)
    h.write(txtLine)
    h.write('\n')

f.close()
h.close()
# Open stim file
f = open(''.join(['stim\\stimMaster.txt']),'r')
g = csv.reader(f,delimiter = '\t')
# Assign correct reponses to items
allItems = []
skip = 0
for line in g:
	# if line[-1] == '0': # Condition column: 1 = Linked, 0 = Non-Linked
	# 	line[-1] = responses[0]
	# elif line[-1] == '1':
	# 	line[-1] = responses[1]
# 	if subNum % 2 == 1 and skip == 1:
# 		newLine = [[],[],[],[],[],[],[],[]]
# 		# newLine = line
# 		newLine[0] = line[0]
# 		newLine[1] = line[1]
# 		newLine[2] = line[2]
# 		newLine[3] = line[4]
# 		newLine[4] = line[3]
# 		newLine[5] = line[5]
# 		newLine[6] = line[6]
# 		newLine[7] = line[7]
# 		line = newLine
	allItems.append(line)
# 	skip = 1

#### new def
def checkRepeats(block,inarow,col):
	for i, sent in enumerate(block):
		if i == 0:
			pass
		elif sent[col] == block[i-1][col]:
			inarow += 1
		else:
			inarow = 1
		if inarow > maxRep:
			break
	return inarow


# Shuffle
random.shuffle(allItems) # Shuffle all the sentences
newStim = []
## new def demands this
rpt,rptRep,carryOver = maxRep + 1,maxRep + 1, 1

for block in range(30): # 6 categories x 30 blocks = 180 items
	currBlock = []
	# For each block, find the first sentence with the desired category and append to block
	for cat in catLabels:
		toPop = []
		for i in range(len(allItems)):
			if allItems[i][-2] == str(cat): # -2 : conditionDetail
				toPop.append(i)
				currBlock.append(allItems[i])
				break
		toPop.sort(reverse = True)
		for j in toPop: # Remove items that have been put in blocks
			allItems.pop(j)
	random.shuffle(currBlock)
	# while block > 0 and newStim[-1][-2] ==  currBlock[0][-2]: # -2 : conditionDetail
	# 	random.shuffle(currBlock)
	while rpt > maxRep or rptRep > maxRep:
		random.shuffle(currBlock)
		if block > 0 and newStim[-1][5] == currBlock[0][5]:
			rpt = checkRepeats(currBlock, carryOver + 1,5)
		else:
			rpt = checkRepeats(currBlock, 1,5)
		if block > 0 and newStim[-1][7] == currBlock[0][7]:
			rptRep = checkRepeats(currBlock, carryOverRep + 1,7)
		else:
			rptRep = checkRepeats(currBlock, 1,7)

	for sent in currBlock:
		newStim.append(sent) # Add sentences to stimulus list

### new def demands this
	carryOver = rpt
	carryOverRep = rptRep
	rpt = maxRep + 1
	rptRep = maxRep + 1
# Save text files and subject flag
f.close()
# f = open(''.join(['SWOPstims\\stimTextFiles\\SUBJECT',str(subNum),'.txt']),'w')
# f.close()

totItems = len(newStim)
iPerList = int(totItems / nLists)

# for listNum in range(1, nLists + 1):
# 	f = open(''.join(['visualStim\\stimTextFiles\\stimBlock',str(listNum),'.txt']),'w')
# 	f.write('\t'.join(allItems[0]))
# 	f.write('\n')
# 	start = (listNum-1)*(iPerList)
# 	for sent in newStim[start : start + iPerList]:
# 		f.write('\t'.join(sent))
# 		# f.write('\t'.join(list(sent[0:2]) + [sent[2] + str(listNum)] + list(sent[3:]) ))
# 		f.write('\n')
# f.close()

# Save trial order for subject
# f = open(''.join(['SWOPstims/subjectStims/ajtTrialOrderSub',str(subNum),'.txt']),'w')
f = open(''.join(['stim\\TrialOrderSub',str(subNum),'.txt']),'w')
f.write('\t'.join(['Weight','Nested','Procedure','colA','colB','condition','conditionDetail','correctResponse\n']))
for line in newStim:
	f.write('\t'.join(line))
	f.write('\n')
f.close()

# # Save instructions
# if responses[0] == 'f':
#     f = open('visualStim\\expInstrJ.txt','r')
# else:
#     f = open('visualStim\\expInstrF.txt','r')
# g = csv.reader(f,delimiter = '\t')
# f2 = open(''.join(['visualStim\\stimTextFiles\\expInstr',str(subNum),'.txt']),'w')
#
# for line in g:
# 	f2.write('\t'.join(line))
# 	f2.write('\n')
# f.close()
# f2.close()
