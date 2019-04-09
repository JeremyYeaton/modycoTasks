# -*- coding: utf-8 -*-
'''
Stroop task in French (adaptable for other languages)
Author: Jeremy Yeaton
24 March 2019
'''

import expyriment as xpy, random as rnd

subNum = int(input("Subject number: "))
'''
add block of colored/uncolored but only respond to word content?
add time piece to instructions
'''

xpy.control.set_develop_mode(True)
exp = xpy.design.Experiment(name="Stroop French")
xpy.control.initialize(exp)

"""Define colors"""
Vars = {'g':['VERT',xpy.misc.constants.C_GREEN],
		'r': ['ROUGE',xpy.misc.constants.C_RED],
		'b': ['BLEU',xpy.misc.constants.C_BLUE],
		'y': ['JAUNE',xpy.misc.constants.C_YELLOW]
		}

n_scrambles = 2
#blockNumber = 0
repNums = [100,102,106,107]
repKeys = ['D','F','J','K']
a = [key for key in Vars.keys()]
rnd.shuffle(a)

xCoord = [-100,-50,50,100]
repKeyVars = [0,0,0,0]
yCoord = -200
side = 40

for i, j in enumerate(a):
	Vars[j].append(repKeys[i])
	Vars[j].append(repNums[i])
clrs = [key for key in Vars]
clrTrials = []
for c1 in clrs:
	for c2 in clrs:
		clrTrials.append(''.join([c1,c2]))

wordDict = {'g':Vars['g'][0],
			'r':Vars['r'][0],
			'b': Vars['b'][0],
			'y': Vars['y'][0],
			't':'CHAT',
			'n':'CHIEN',
			'm':'MAIN',
			'p':'PIED'}

trial_types = [['gR','rR','bR','yR'],['gW','rW','bW','yW'],
			   ['gg','gb','gr','gy','bb','bg','br','by','rr','rb','rg','ry','yy',
				   'yr','yb','yg','tg','tb','tr','ty','ng','nb','nr','ny','mg',
				   'mb','mr','my','pg','pb','pr','py'],[]]
for tType in clrTrials:
	trial_types[3].append(tType)
	for t in trial_types[1]:
		trial_types[3].append(t)
trial_types

keyAssign = (Vars[a[0]][0],Vars[a[1]][0],Vars[a[2]][0],Vars[a[3]][0])
blockNames = ["IntroRect",0,"IntroBW",1,"IntroClr",2,"IntroSwitch",3]
instructions = {}

rectInstr = """Tu vas voir apparaitre des rectangles de couleur sur l’écran. 
Tu vas devoir appuyer sur la touche qui correspond à la couleur vue sur l’écran.
Si un rectangle rouge apparait, tu dois appuyer sur la couleur rouge.\n
Appuie sur ESPACE pour continuer."""

timeInstr = """Essaie d’être aussi rapide et correcte que possible ! 
Si tu réponds pas assez rapidement, tu passeras automatiquement à l’item suivant.\n
Appuie sur ESPACE pour continuer."""

repere = """Avant de commencer, repère bien les couleurs sur le clavier:
%s, appuie sur D.\n %s, appuie sur F.\n %s, appuie sur J\n %s, appuie sur K.\n
Appuie sur ESPACE pour essayer."""%keyAssign

txtInstr = """Tu vas voir apparaitre sur l’écran des mots du lexique des couleurs. 
Ces mots sont écrits en noir et blanc. 
Tu vas devoir appuyer sur la touche qui correspond à la couleur exprimée par le mot. 
Si le mot ROUGE apparait, tu dois appuyer sur la couleur rouge.\n
Appuie sur ESPACE pour continuer."""

cTxtInstr = """Maintenant, tu vas voir apparaitre sur l’écran des mots qui feront référence 
soit au lexique des couleurs, soit au lexique courant du français. 
Ces mots sont écrits dans différentes couleurs, et tu vas devoir 
appuyer sur la touche qui correspond à la couleur dans laquelle le mot est écrit. 
Si le mot JAUNE est écrit en rouge, tu dois appuyer sur la couleur rouge.\n
Appuie sur ESPACE pour continuer."""

sendOff = """Tres bien!\n\n 
Appuie sur ESPACE pour commencer."""

retryTxt = """Pas exactement. Rappel:
%s, appuie sur D.\n %s, appuie sur F.\n %s, appuie sur J\n %s, appuie sur K.\n\n 
Appuie sur ESPACE pour ressayer."""%keyAssign

instr = [rectInstr, txtInstr, cTxtInstr]

def instrTrial(Instructions,block_name):
	trial_name = xpy.design.Trial()
	stim = xpy.stimuli.TextBox(Instructions,(750,300),(0,-100))
	stim.preload()
	trial_name.add_stimulus(stim)
	block_name.add_trial(trial_name)
	
def rectTrial(trial_name, block_name):
	t_name = trial_name[0]
	clr = Vars[t_name][1]
	trial_name = xpy.design.Trial()
	stim = xpy.stimuli.Rectangle(size = (100,50),colour = clr)
	stim.preload()
	trial_name.add_stimulus(stim)
	for i in range(0,4):
		stim = xpy.stimuli.Rectangle(size = (50,50),colour = Vars[a[i]][1], position = (xCoord[i],-100))
		stim.preload()
		trial_name.add_stimulus(stim)
	trial_name.set_factor(name = "Type", value = 'rect')
	trial_name.set_factor(name = "Color", value = t_name)
	trial_name.set_factor(name = "Text", value = 'NA')
	trial_name.set_factor(name = "Letter", value = Vars[t_name][3])
	block_name.add_trial(trial_name)

def bwTrial(trial_name, block_name):
	t_name = trial_name[0]
	cText = Vars[t_name][0]
	trial_name = xpy.design.Trial()
	stim = xpy.stimuli.TextLine(cText,text_size = 48, text_bold = True)
	stim.preload()
	trial_name.add_stimulus(stim)
	trial_name.set_factor(name = "Type", value = 'bw')
	trial_name.set_factor(name = "Color", value = 'NA')
	trial_name.set_factor(name = "Text", value = t_name)
	trial_name.set_factor(name = "Letter", value = Vars[t_name][3])
	block_name.add_trial(trial_name)

def clrTrial(trial_name, block_name):
	t_name = trial_name
	[txtName, clrName] = [t_name[0], t_name[1]] 
	[cText,txtClr] = [wordDict[txtName], Vars[clrName][1]]
	trial_name = xpy.design.Trial()
	stim = xpy.stimuli.TextLine(cText,text_size = 48, text_bold = True, text_colour = txtClr)
	stim.preload()
	trial_name.add_stimulus(stim)
	if t_name[0] == t_name[1]:
		trial_name.set_factor(name = "Type", value = 'cong')
	elif t_name[0] in Vars:
		trial_name.set_factor(name = "Type", value = 'incong')
	else:
		trial_name.set_factor(name = "Type", value = 'neut')
	trial_name.set_factor(name = "Color", value = clrName)
	trial_name.set_factor(name = "Text", value = txtName)
	trial_name.set_factor(name = "Letter", value = Vars[clrName][3])
	block_name.add_trial(trial_name)
	
def addBlock(block, prac = bool):
	blockNum = block
	if prac == True:
		trials = xpy.design.randomize.make_multiplied_shuffled_list(trial_types[blockNum],2)
		trials = rnd.choices(trials,k=5)
		block = ''.join([str(blockNum),' Practice'])
	else:
		trials = xpy.design.randomize.make_multiplied_shuffled_list(trial_types[blockNum],n_scrambles)
	block = xpy.design.Block(name = block)
	for trial in trials:
		if trial[1] == 'R':
			rectTrial(trial,block)
		elif trial[1] == 'W':
			bwTrial(trial,block)
		else:
			clrTrial(trial,block)
	exp.add_block(block)

for Idx, key in enumerate(repKeys):
	repKeyVars[Idx] = xpy.stimuli.TextBox(repKeys[Idx], size = (side,side),text_colour = xpy.misc.constants.C_BLACK, 
						text_bold = True, background_colour = Vars[a[Idx]][1],position = (xCoord[Idx],yCoord))
	repKeyVars[Idx].preload()
	
def keyPresent():
	repKeyVars[0].present(clear = True,update = False)
	repKeyVars[1].present(clear = False,update = False)
	repKeyVars[2].present(clear = False,update = False)
	repKeyVars[3].present(clear = False,update = False)
	
blockNames = ["IntroRect",0,"IntroBW",1,"IntroClr",2]
instrNum = 0

for blck in blockNames:
	if type(blck) == str:
		Block = xpy.design.Block(name = blck)
		instrTrial(instr[instrNum],Block)
		instrTrial(timeInstr,Block)
		instrTrial(repere,Block)
		exp.add_block(Block)
		instrNum += 1
	elif type(blck) == int:
		addBlock(blck,prac = 1)
		addBlock(blck)

def presentInstr(blockNum):
	for block in exp.blocks[blockNum:blockNum + 1]:
		for trial in block.trials:
			trial.stimuli[0].present(clear = True, update = True)
			exp.keyboard.wait(xpy.misc.constants.K_SPACE)
			
def presentBlock(blockNum,prac = int):
	ready = False
	while ready == False:
		err = 0
		for block in exp.blocks[blockNum:blockNum + 1]:
			for trial in block.trials:
				keyPresent()
				cross.present(clear = False, update = True)
				exp.clock.wait(rnd.randint(500,1000))
				keyPresent()
				trial.stimuli[0].present(clear = False, update= True)
				key, rt = exp.keyboard.wait([xpy.misc.constants.K_d,
		                                     xpy.misc.constants.K_f,
											  xpy.misc.constants.K_j,
											  xpy.misc.constants.K_k]
											,duration = 1500)
				exp.data.add([block.name, trial.id, trial.get_factor("Type"), 
						trial.get_factor("Color"), trial.get_factor("Text") ,
						trial.get_factor("Letter"), key, rt])
				if key != trial.get_factor("Letter"):
					err += 1
				blank.present(clear = True, update= False)
				keyPresent()
				repKeyVars[3].present(clear = False,update = True)
				exp.clock.wait(500)
		if prac != 1:
			ready = True
		elif err < 3 and prac == 1:
			ready = True
			sendoff.present()
			exp.keyboard.wait(xpy.misc.constants.K_SPACE)
		else:
			retry.present()
			exp.keyboard.wait(xpy.misc.constants.K_SPACE)
		
	
cross = xpy.stimuli.FixCross((25,25),(0,0),4)
cross.preload()

blank = xpy.stimuli.BlankScreen()
blank.preload()

sendoff = xpy.stimuli.TextBox(sendOff,(750,300),(0,-100))
sendoff.preload()
retry = xpy.stimuli.TextBox(retryTxt,(750,300),(0,-100))
retry.preload()

exp.data_variable_names = ["Block", "Trial", "Type", "Color", "Text", "Letter", "Key", "RT"]

xpy.control.start(skip_ready_screen = True,subject_id = subNum)
blNum = 0
for i in range(0,4):
	presentInstr(blNum)
	blNum += 1
	presentBlock(blNum,prac = 1)
	blNum += 1
	presentBlock(blNum)
	blNum += 1

xpy.control.end()