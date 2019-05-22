import os, csv, random

# os.chdir('/Users/yaruwu/MEGA/_PojetEEG/1_Stimuli')
# os.chdir('F:\\BILCHIN\\pyPourEEG_read')

#%%
catLabels = ["SpoA","SpoB","sPo","spO","spoA","spoB"]  
#conditionNb: 	1,		1,	2,		3,		4,	4
subNum = int(input("Subject number: "))

nLists = 3

# #### CHOOSE FROM DIFFERNT CONDITIONS
# # Assign list number to even/odd subjects
# if subNum % 2 == 1:
# 	listNum = 1
# else:
# 	listNum = 2

# Assign response category to alternate every 2 participants
if subNum % 4 < 2:  # ex. sujet 1,sujet 4
	responses = ['f','j'] # notlinked, linked
else: # ex. sujet 2,sujet 3
	responses = ['j','f'] # notlinked, linked
# Open practice stim file
f = open('SWOPstims\\practice.txt','r',encoding='utf-8')
g = csv.reader(f,delimiter = '\t')
# h = open('SWOPstims/stimTextFiles/practiceBlock.txt','w',encoding='utf-8')
h = open('SWOPstims\\stimTextFiles\\practiceBlock.txt','w',encoding='utf-8')
for line in g:
    if line[-1] == '0': # Condition column: 0 = notLinked ; 1  = linked
        line[-1] = responses[0]
    elif line[-1] == '1':
        line[-1] = responses[1]
    # txtLine = '\t'.join(line)
    txtLine = '\t'.join(list(line[0:3]) + ["wav\\" + line[3] + ".wav"] + ["wav\\" + line[4] + ".wav"] + list(line[5:]) )
    h.write(txtLine)
    h.write('\n')

f.close()
h.close()
# Open stim file
#f = open(''.join(['ERP_stims\\stimList',str(listNum),'.txt']),'r',encoding='utf-8')
# f = open(''.join(['SWOPstims\\stimList',str(listNum),'.txt']),'r',encoding='utf-8')
# f = open(''.join(['SWOPstims/stimList.txt']),'r',encoding='utf-8')
f = open(''.join(['SWOPstims\\stimList.txt']),'r',encoding='utf-8')
g = csv.reader(f,delimiter = '\t')
# Assign correct reponses to items
allItems = []
for line in g:
	if line[-1] == '0': # Condition column: 1 = Linked, 0 = Non-Linked
		line[-1] = responses[0]
	elif line[-1] == '1':
		line[-1] = responses[1]
	if subNum % 2 == 1:
		newLine = [[],[],[],[],[],[],[],[]]
		# newLine = line
		newLine[0] = line[0]
		newLine[1] = line[1]
		newLine[2] = line[2]
		newLine[3] = line[4]
		newLine[4] = line[3]
		newLine[5] = line[5]
		newLine[6] = line[6]
		newLine[7] = line[7]
		line = newLine
	allItems.append(line)

# Shuffle
random.shuffle(allItems) # Shuffle all the sentences
newStim = []
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
	while block > 0 and newStim[-1][-2] ==  currBlock[0][-2]: # -2 : conditionDetail
		random.shuffle(currBlock)
	for sent in currBlock:
		newStim.append(sent) # Add sentences to stimulus list
# Save text files and subject flag
f.close()
# f = open(''.join(['SWOPstims\\stimTextFiles\\SUBJECT',str(subNum),'.txt']),'w',encoding='utf-8')
# f.close()

totItems = len(newStim)
iPerList = int(totItems / nLists)

for listNum in range(1, nLists + 1):
	f = open(''.join(['SWOPstims\\stimTextFiles\\stimBlock',str(listNum),'.txt']),'w',encoding='utf-8')
	f.write('\t'.join(allItems[0]))
	f.write('\n')
	start = (listNum-1)*(iPerList)
	for sent in newStim[start : start + iPerList]:
		# f.write('\t'.join(sent))
		f.write('\t'.join(list(sent[0:3]) + ["wav\\" + sent[3] + ".wav"] + ["wav\\" + sent[4] + ".wav"] + list(sent[5:]) ))
		# f.write('\t'.join(list(sent[0:2]) + [sent[2] + str(listNum)] + list(sent[3:]) ))
		f.write('\n')
f.close()

# Save trial order for subject
# f = open(''.join(['SWOPstims/subjectStims/ajtTrialOrderSub',str(subNum),'.txt']),'w',encoding='utf-8')
f = open(''.join(['SWOPstims\\subjectStims\\ajtTrialOrderSub',str(subNum),'.txt']),'w',encoding='utf-8')
for line in newStim:
	f.write('\t'.join(line))
	f.write('\n')
f.close()

# Save instructions
if responses[0] == 'f':
    f = open('SWOPstims\\expInstrJ.txt','r',encoding='utf-8')
else:
    f = open('SWOPstims\\expInstrF.txt','r',encoding='utf-8')
g = csv.reader(f,delimiter = '\t')
f2 = open(''.join(['SWOPstims\\stimTextFiles\\expInstr',str(subNum),'.txt']),'w',encoding='utf-8')

for line in g:
	f2.write('\t'.join(line))
	f2.write('\n')
f.close()
f2.close()
