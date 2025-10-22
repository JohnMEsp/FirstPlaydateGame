-- Put your utilities and other helper functions here.
-- The "Utilities" table is already defined in "noble/Utilities.lua."
-- Try to avoid name collisions.

function Utilities.getZero()
	return 0
end


-- Global variables
GamePlayingField = nil


-- Define useful functions
function drawCards(deck, numCardsToDraw)
	local drawnCards = {}
	for i = 1, numCardsToDraw do
		if #deck == 0 then break end
		local idx = math.random(1, #deck)
		table.insert(drawnCards, deck[idx])
		table.remove(deck, idx)
	end
	return drawnCards
end

function removeCard(deck, cardToRemove)
	for i = #deck, 1, -1 do
		if deck[i] == cardToRemove then
			table.remove(deck, i)
			break
		end
	end
end

function copyTable(orig)
	local copy = {}
	for k, v in pairs(orig) do
		copy[k] = v
	end
	return copy
end

function increaseSpaceCost(currentCost)
	local maxCost = 12
	if currentCost < maxCost then
		return currentCost + 1
	else
		return currentCost
	end
end


-- Define Card class
Card = {}
class("Card").extends(Object)
function Card:init(cardName, cost, pro, cash, con, star, ability, image)
	Card.super.init(self)
	self.cardName = cardName
	self.cost     = cost
	self.pro      = pro
	self.cash     = cash
	self.con      = con
	self.star     = star
	self.ability  = ability
	self.image    = image
end


-- Define card collection
CardCollection = {}
class("CardCollection").extends(Object)
function CardCollection:init()
	CardCollection.super.init(self)

	-- Starting cards
	self.oldFriendCard = Card("Old Friend",   2, 1, 0, 0, 0, nil, "assets/images/cards/OldFriend")
	self.richPalCard   = Card("Rich Pal",     3, 0, 1, 0, 0, nil, "assets/images/cards/RichPal")
	self.wildBuddyCard = Card("Wild Buddy", nil, 2, 0, 1, 0, nil, "assets/images/cards/WildBuddy")  -- Not Purchasable

	-- Purchasable Cards (11 in shop)
	self.hippyCard       = Card("Hippy",        4, 1,  0, -1, 0, nil, "assets/images/cards/Hippy")
	self.gamblerCard     = Card("Gambler",      7, 2,  3,  1, 0, nil, "assets/images/cards/Gambler")
	self.privateEyeCard  = Card("Private Eye",  4, 2, -1,  2, 0, nil, "assets/images/cards/PrivateEye")
	self.cuteDog         = Card("Cute Dog",     7, 2,  0, -1, 0, nil, "assets/images/cards/CuteDog")
	self.wrestlerCard    = Card("Wrestler",     9, 2,  0,  0, 0, nil, "assets/images/cards/Wrestler")
	self.watchDogCard    = Card("Watch Dog",    4, 2,  0,  0, 0, nil, "assets/images/cards/WatchDog")
	self.spyCard         = Card("Spy",          8, 0,  2,  0, 0, nil, "assets/images/cards/Spy")
	self.grillmasterCard = Card("Grillmaster",  5, 2,  0,  0, 0, nil, "assets/images/cards/Grillmaster")
	self.athleteCard     = Card("Athlete",      6, 1,  1,  0, 0, nil, "assets/images/cards/Athlete")
	self.mrPopularCard   = Card("Mr Popular",   5, 3,  0,  0, 0, nil, "assets/images/cards/MrPopular")
	self.celebrityCard   = Card("Celebrity",   11, 2,  3,  0, 0, nil, "assets/images/cards/Celebrity")

	-- Star Cards (2 in shop)
	self.alienCard      = Card("Alien",      40, 0, 0, 0, 1, nil, "assets/images/cards/Alien")
	self.leprechaunCard = Card("Leprechaun", 30, 0, 3, 0, 1, nil, "assets/images/cards/Leprechaun")

	-- Group card types for shop building
	self.nonStarTypes = {
		self.hippyCard,
		self.gamblerCard,
		self.privateEyeCard,
		self.cuteDog,
		self.wrestlerCard,
		self.watchDogCard,
		self.spyCard,
		self.grillmasterCard,
		self.athleteCard,
		self.mrPopularCard,
		self.celebrityCard
	}

	self.starTypes = {
		self.alienCard,
		self.leprechaunCard
	}

	self.nonStarShop = {}
	self.starShop = {}
end

function CardCollection:buildNonStarShop()
	local builtNonStarShop = {
		self.oldFriendCard, self.oldFriendCard, self.oldFriendCard, self.oldFriendCard,
		self.richPalCard, self.richPalCard, self.richPalCard, self.richPalCard
	}

	local nonStarCards = drawCards(copyTable(self.nonStarTypes), 11)
	for _, card in ipairs(nonStarCards) do
		for i = 1, 4 do  -- Add 4 copies of each drawn card
			table.insert(builtNonStarShop, card)
		end
	end

	self.nonStarShop = builtNonStarShop
end

function CardCollection:buildStarShop()
	local starCards = drawCards(copyTable(self.starTypes), 2)
	self.starShop = starCards
end


-- Define PlayingField class
PlayingField = {}
class("PlayingField").extends(Object)
function PlayingField:init()
	PlayingField.super.init(self)

	-- Initialize card collection
	self.cardCollection = CardCollection()
	self.cardCollection:buildNonStarShop()
	self.cardCollection:buildStarShop()

	-- Initialize player's starting cards
	self.deckOwned = {
		self.cardCollection.oldFriendCard, self.cardCollection.oldFriendCard, self.cardCollection.oldFriendCard, self.cardCollection.oldFriendCard,
		self.cardCollection.richPalCard, self.cardCollection.richPalCard,
		self.cardCollection.wildBuddyCard, self.cardCollection.wildBuddyCard, self.cardCollection.wildBuddyCard, self.cardCollection.wildBuddyCard
	}

	-- Will update during a turn
	self.remainingDeck = {}
	self.cardsInPlay = {}

	self.spaceUsed = 0  -- Max fieldTotal
	self.conCount  = 0  -- Max 3
	self.starCount = 0  -- Max 4

	-- Build shops for card purchasing
	self.nonStarShop    = self.cardCollection.nonStarShop
	self.starShop       = self.cardCollection.starShop
	self.extraSpaceCost = 2

	-- Global game stats
	self.turnsTaken = 0
	self.fieldTotal = 5
	self.proTotal   = 0  -- Max 65
	self.cashTotal  = 0  -- Max 30

	self.continueGame = true
	self.gameWon = false
end


-- Implement game logic
-- Flow goes as follows: startTurn -> progressTurn (repeats) -> endTurn -> purchaseFromShop (optional)
function PlayingField:startTurn()
	self.remainingDeck = copyTable(self.deckOwned)
	self.cardsInPlay = {}

	self.spaceUsed = 0
	self.conCount = 0
	self.starCount = 0
end

function PlayingField:progressTurn()
	local isTurnContinue = true

	-- Draw card from deck and add to space used
	drawnCardFromDeck = drawCards(self.remainingDeck, 1)[1]
	self.cardsInPlay[#self.cardsInPlay + 1] = drawnCardFromDeck
	self.spaceUsed = self.spaceUsed + 1


	-- End turn if con count exceeds 3
	self.conCount = self.conCount + drawnCardFromDeck.con
	if self.conCount >= 3 then
		return false
	end
	-- End turn if there's an overflow of space
	if self.spaceUsed > self.fieldTotal then
		isTurnContinue = false
	end


	-- Update pro and cash totals
	self.proTotal = self.proTotal + drawnCardFromDeck.pro
	if self.proTotal > 65 then
		self.proTotal = 65
	end
	self.cashTotal = self.cashTotal + drawnCardFromDeck.cash
	if self.cashTotal > 30 then
		self.cashTotal = 30
	end


	-- Game ends if 4 stars are collected
	self.starCount = self.starCount + drawnCardFromDeck.star
	if self.starCount >= 4 then
		return false
	end


	-- End turn if no cards remain in deck
	if self.remainingDeck == nil then
		return false
	end
	-- End turn if field is full
	if self.spaceUsed == self.fieldTotal then
		return false
	end

	return isTurnContinue
end

function PlayingField:endTurn()
	self.turnsTaken = self.turnsTaken + 1

	if self.starCount >= 4 then
		self.continueGame = false
		self.gameWon = true
	end

	if self.turnsTaken >= 25 then
		self.continueGame = false
		self.gameWon = false
	end

	return self.continueGame
end

function PlayingField:purchaseFromShop(purchaseType, cost, purchase)
	if cost <= self.cashTotal then
		self.cashTotal = self.cashTotal - cost
	else
		return false
	end

	if purchaseType == "nonStar" then
		removeCard(self.nonStarShop, purchase)
		self.deckOwned[#self.deckOwned + 1] = purchase
	elseif purchaseType == "star" then
		self.deckOwned[#self.deckOwned + 1] = purchase
	elseif purchaseType == "extraSpace" then
		self.fieldTotal = self.fieldTotal + 1
		self.extraSpaceCost = increaseSpaceCost(self.extraSpaceCost)
	end

	return true
end