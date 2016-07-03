//
//  UIColor.swift
//  Tuiteur
//
//  Created by Kevin Launay on 6/17/16.
//  Copyright © 2016 Kevin Launay. All rights reserved.
//

import Foundation

extension UIColor {

    enum Crayon : String {
        case absolutezero = "0048ba"
        case alienarmpit = "84de02"
        case alloyorange = "c46210"
        case almond = "efdecd"
        case amethyst = "64609a"
        case antiquebrass = "cd9575"
        case apricot = "fdd9b5"
        case aquapearl = "5fbed7"
        case aquamarine = "78dbe2"
        case asparagus = "87a96b"
        case atomictangerine = "ffa474"
        case aztecgold = "c39953"
        case babypowder = "fefefa"
        case banana = "ffd12a"
        case bananamania = "fae7b5"
        case bdazzledblue = "2e5894"
        case beaver = "9f8170"
        case bigdiporuby = "9c2542"
        case bigfootfeet = "e88e5a"
        case bittersweet = "fd7c6e"
        case bittersweetshimmer = "bf4f51"
        case black = "000000"
        case blackcoralpearl = "54626f"
        case blackshadows = "bfafb2"
        case blastoffbronze = "a57164"
        case blizzardblue = "ace5ee"
        case blue = "1f75fe"
        case bluebell = "a2a2d0"
        case bluegray = "6699cc"
        case bluegreen = "0d98ba"
        case bluejeans = "5dadec"
        case blueviolet = "7366bd"
        case blueberry = "4f86f7"
        case blush = "de5d83"
        case boogerbuster = "dde26a"
        case brickred = "cb4154"
        case brightyellow = "ffaa1d"
        case brown = "b4674d"
        case brownsugar = "af6e4d"
        case bubblegum = "ffd3f8"
        case burnishedbrown = "a17a74"
        case burntorange = "ff7f49"
        case burntsienna = "ea7e5d"
        case cadetblue = "b0b7c6"
        case canary = "ffff99"
        case caribbeangreen = "1cd3a2"
        case caribbeangreenpearl = "6ada8e"
        case carnationpink = "ffaacc"
        case cedarchest = "c95a49"
        case cerise = "dd4492"
        case cerulean = "1dacd6"
        case ceruleanfrost = "6d9bc3"
        case cherry = "da2647"
        case chestnut = "bc5d58"
        case chocolate = "bd8260"
        case cinnamonsatin = "cd607e"
        case citrine = "933709"
        case coconut = "fefefe"
        case copper = "dd9475"
        case copperpenny = "ad6f69"
        case cornflower = "9aceeb"
        case cosmiccobalt = "2e2d88"
        case cottoncandy = "ffbcd9"
        case culturedpearl = "f5f5f5"
        case cybergrape = "58427c"
        case daffodil = "ffff31"
        case dandelion = "fddb6d"
        case deepspacesparkle = "4a646c"
        case denim = "2b6cc4"
        case denimblue = "2243b6"
        case desertsand = "efcdb8"
        case dingydungeon = "c53151"
        case dirt = "9b7653"
        case eerieblack = "1b1b1b"
        case eggplant = "6e5160"
        case electriclime = "ceff1d"
        case emerald = "14a989"
        case eucalyptus = "44d7a8"
        case fern = "71bc78"
        case fieryrose = "ff5470"
        case forestgreen = "6dae81"
        case freshair = "a6e7ff"
        case frostbite = "e936a7"
        case fuchsia = "c364c5"
        case fuzzywuzzy = "cc6666"
        case gargoylegas = "ffdf46"
        case giantsclub = "b05c52"
        case glossygrape = "ab92b3"
        case gold = "e7c697"
        case goldfusion = "85754e"
        case goldenrod = "fcd975"
        case granitegray = "676767"
        case grannysmithapple = "a8e4a0"
        case grape = "6f2da8"
        case gray = "95918c"
        case green = "1cac78"
        case greenblue = "1164b4"
        case greenlizard = "a7f432"
        case greensheen = "6eaea1"
        case greenyellow = "f0e891"
        case heatwave = "ff7a00"
        case hotmagenta = "ff1dce"
        case illuminatingemerald = "319177"
        case inchworm = "b2ec5d"
        case indigo = "5d76cb"
        case jade = "469a84"
        case jasper = "d05340"
        case jazzberryjam = "ca3767"
        case jellybean = "da614e"
        case junglegreen = "3bb08f"
        case keylimepearl = "e8f48c"
        case lapislazuli = "436cb9"
        case laserlemon = "fefe22"
        case lavender = "fcb4d5"
        case leatherjacket = "253529"
        case lemon = "ffff38"
        case lemonglacier = "fdff00"
        case lemonyellow = "fff44f"
        case licorice = "1a1110"
        case lilac = "db91ef"
        case lilacluster = "ae98aa"
        case lime = "b2f302"
        case lumber = "ffe4cd"
        case macaronicheese = "ffbd88"
        case magenta = "f664af"
        case magicmint = "aaf0d1"
        case magicpotion = "ff4466"
        case mahogany = "cd4a4c"
        case maize = "edd19c"
        case malachite = "469496"
        case manatee = "979aaa"
        case mandarinpearl = "f37a48"
        case mangotango = "ff8243"
        case maroon = "c8385a"
        case mauvelous = "ef98aa"
        case melon = "fdbcb4"
        case metallicseaweed = "0a7e8c"
        case metallicsunburst = "9c7c38"
        case midnightblue = "1a4876"
        case midnightpearl = "702670"
        case mistymoss = "bbb477"
        case moonstone = "3aa8c1"
        case mountainmeadow = "30ba8f"
        case mulberry = "c54b8c"
        case mummystomb = "828e84"
        case mysticmaroon = "ad4379"
        case mysticpearl = "d65282"
        case navyblue = "1974d2"
        case neoncarrot = "ffa343"
        case newcar = "214fc6"
        case oceanbluepearl = "4f42b5"
        case oceangreenpearl = "48bf91"
        case ogreodor = "fd5240"
        case olivegreen = "bab86c"
        case onyx = "353839"
        case orange = "ff7538"
        case orangered = "ff2b2b"
        case orangesoda = "fa5b3d"
        case orangeyellow = "f8d568"
        case orchid = "e6a8d7"
        case orchidpearl = "7b4259"
        case outerspace = "414a4c"
        case outrageousorange = "ff6e4a"
        case pacificblue = "1ca9c9"
        case peach = "ffcfab"
        case pearlypurple = "b768a2"
        case peridot = "abad48"
        case periwinkle = "c5d0e6"
        case pewterblue = "8ba8b7"
        case piggypink = "fddde6"
        case pine = "45a27d"
        case pinegreen = "158078"
        case pinkflamingo = "fc74fd"
        case pinkpearl = "b07080"
        case pinksherbert = "f78fa7"
        case pixiepowder = "391285"
        case plum = "8e4585"
        case plumppurple = "5946b2"
        case polishedpine = "5da493"
        case princessperfume = "ff85cf"
        case purpleheart = "7442c8"
        case purplemountainsmajesty = "9d81ba"
        case purplepizzazz = "fe4eda"
        case purpleplum = "9c51b6"
        case quicksilver = "a6a6a6"
        case radicalred = "ff496c"
        case rawsienna = "d68a59"
        case rawumber = "714b23"
        case razzledazzlerose = "ff48d0"
        case razzmatazz = "e3256b"
        case razzmicberry = "8d4e85"
        case red = "ee204d"
        case redorange = "ff5349"
        case redsalsa = "fd3a4a"
        case redviolet = "c0448f"
        case robinseggblue = "1fcecb"
        case rose = "ff5050"
        case rosedust = "9e5e6f"
        case rosepearl = "f03865"
        case rosequartz = "bd559c"
        case royalpurple = "7851a9"
        case ruby = "aa4069"
        case rustyred = "da2c43"
        case salmon = "ff9baa"
        case salmonpearl = "f1444a"
        case sapphire = "2d5da1"
        case sasquatchsocks = "ff4681"
        case scarlet = "fc2847"
        case screamingreen = "76ff7a"
        case seagreen = "9fe2bf"
        case seaserpent = "4bc7cf"
        case sepia = "a5694f"
        case shadow = "8a795d"
        case shadowblue = "778ba5"
        case shampoo = "ffcff1"
        case shamrock = "45cea2"
        case sheengreen = "8fd400"
        case shimmeringblush = "d98695"
        case shinyshamrock = "5fa778"
        case shockingpink = "fb7efd"
        case silver = "cdc5c2"
        case sizzlingred = "ff3855"
        case sizzlingsunrise = "ffdb00"
        case skyblue = "80daeb"
        case slimygreen = "299617"
        case smashedpumpkin = "ff6d3a"
        case smoke = "738276"
        case smokeytopaz = "832a0d"
        case soap = "cec8ef"
        case sonicsilver = "757575"
        case springfrost = "87ff2a"
        case springgreen = "eceabe"
        case steelblue = "0081ab"
        case steelteal = "5f8a8b"
        case strawberry = "fc5a8d"
        case sugarplum = "914e75"
        case sunburntcyclops = "ff404c"
        case sunglow = "ffcf48"
        case sunnypearl = "f2f27a"
        case sunsetorange = "fd5e53"
        case sunsetpearl = "f1cc79"
        case sweetbrown = "a83731"
        case tan = "faa76c"
        case tartorange = "fb4d46"
        case tealblue = "18a7b5"
        case thistle = "ebc7df"
        case ticklemepink = "fc89ac"
        case tigerseye = "b56917"
        case timberwolf = "dbd7d2"
        case tropicalrainforest = "17806d"
        case tulip = "ff878d"
        case tumbleweed = "deaa88"
        case turquoiseblue = "77dde7"
        case turquoisepearl = "3bbcd0"
        case twilightlavender = "8a496b"
        case unmellowyellow = "ffff66"
        case violetblue = "324ab2"
        case violetpurple = "926eae"
        case violetred = "f75394"
        case vividtangerine = "ffa089"
        case vividviolet = "8f509d"
        case white = "ffffff"
        case wildblueyonder = "a2add0"
        case wildstrawberry = "ff43a4"
        case wildwatermelon = "fc6c85"
        case wintersky = "ff007c"
        case winterwizard = "a0e6ff"
        case wintergreendream = "56887d"
        case wisteria = "cda4de"
        case yellow = "fce883"
        case yellowgreen = "c5e384"
        case yelloworange = "ffb653"
        case yellowsunshine = "fff700"
        
        static let all = [absolutezero, alienarmpit, alloyorange, almond, amethyst, antiquebrass, apricot, aquapearl, aquamarine, asparagus, atomictangerine, aztecgold, babypowder, banana, bananamania, bdazzledblue, beaver, bigdiporuby, bigfootfeet, bittersweet, bittersweetshimmer, black, blackcoralpearl, blackshadows, blastoffbronze, blizzardblue, blue, bluebell, bluegray, bluegreen, bluejeans, blueviolet, blueberry, blush, boogerbuster, brickred, brightyellow, brown, brownsugar, bubblegum, burnishedbrown, burntorange, burntsienna, cadetblue, canary, caribbeangreen, caribbeangreenpearl, carnationpink, cedarchest, cerise, cerulean, ceruleanfrost, cherry, chestnut, chocolate, cinnamonsatin, citrine, coconut, copper, copperpenny, cornflower, cosmiccobalt, cottoncandy, culturedpearl, cybergrape, daffodil, dandelion, deepspacesparkle, denim, denimblue, desertsand, dingydungeon, dirt, eerieblack, eggplant, electriclime, emerald, eucalyptus, fern, fieryrose, forestgreen, freshair, frostbite, fuchsia, fuzzywuzzy, gargoylegas, giantsclub, glossygrape, gold, goldfusion, goldenrod, granitegray, grannysmithapple, grape, gray, green, greenblue, greenlizard, greensheen, greenyellow, heatwave, hotmagenta, illuminatingemerald, inchworm, indigo, jade, jasper, jazzberryjam, jellybean, junglegreen, keylimepearl, lapislazuli, laserlemon, lavender, leatherjacket, lemon, lemonglacier, lemonyellow, licorice, lilac, lilacluster, lime, lumber, macaronicheese, magenta, magicmint, magicpotion, mahogany, maize, malachite, manatee, mandarinpearl, mangotango, maroon, mauvelous, melon, metallicseaweed, metallicsunburst, midnightblue, midnightpearl, mistymoss, moonstone, mountainmeadow, mulberry, mummystomb, mysticmaroon, mysticpearl, navyblue, neoncarrot, newcar, oceanbluepearl, oceangreenpearl, ogreodor, olivegreen, onyx, orange, orangered, orangesoda, orangeyellow, orchid, orchidpearl, outerspace, outrageousorange, pacificblue, peach, pearlypurple, peridot, periwinkle, pewterblue, piggypink, pine, pinegreen, pinkflamingo, pinkpearl, pinksherbert, pixiepowder, plum, plumppurple, polishedpine, princessperfume, purpleheart, purplemountainsmajesty, purplepizzazz, purpleplum, quicksilver, radicalred, rawsienna, rawumber, razzledazzlerose, razzmatazz, razzmicberry, red, redorange, redsalsa, redviolet, robinseggblue, rose, rosedust, rosepearl, rosequartz, royalpurple, ruby, rustyred, salmon, salmonpearl, sapphire, sasquatchsocks, scarlet, screamingreen, seagreen, seaserpent, sepia, shadow, shadowblue, shampoo, shamrock, sheengreen, shimmeringblush, shinyshamrock, shockingpink, silver, sizzlingred, sizzlingsunrise, skyblue, slimygreen, smashedpumpkin, smoke, smokeytopaz, soap, sonicsilver, springfrost, springgreen, steelblue, steelteal, strawberry, sugarplum, sunburntcyclops, sunglow, sunnypearl, sunsetorange, sunsetpearl, sweetbrown, tan, tartorange, tealblue, thistle, ticklemepink, tigerseye, timberwolf, tropicalrainforest, tulip, tumbleweed, turquoiseblue, turquoisepearl, twilightlavender, unmellowyellow, violetblue, violetpurple, violetred, vividtangerine, vividviolet, white, wildblueyonder, wildstrawberry, wildwatermelon, wintersky, winterwizard, wintergreendream, wisteria, yellow, yellowgreen, yelloworange, yellowsunshine]
        
        func getUIColor() -> UIColor {
            
            return  UIColor(rgbString: self.rawValue)!
        }
        
        static func getCrayon(rgbString: String) -> Crayon {
            
            let tolerance = 0.10
            
            let rgb = UIColor.getRGB(rgbString)
            
            let amount = Double(rgb.red + rgb.green + rgb.blue)
            let amountRed = Double(rgb.red) / amount
            let amountGreen = Double(rgb.green) / amount
            let amountBlue = Double(rgb.blue) / amount
            
            var selectedCrayon = black
            
            var amountForSelectedCrayon = 0.0
            
            for value in all {
                
                let crayon = (hex: value.rawValue, color: UIColor(rgbString: value.rawValue) ?? UIColor.blackColor() , rgb: UIColor.getRGB(value.rawValue))
                
                let currentAmount = Double(crayon.rgb.red + crayon.rgb.green + crayon.rgb.blue)
                let currentAmountRed = Double(crayon.rgb.red) / currentAmount
                let currentAmountGreen = Double(crayon.rgb.green) / currentAmount
                let currentAmountBlue = Double(crayon.rgb.blue) / currentAmount
                
                let deltaRed = currentAmountRed - amountRed
                let deltaGreen = currentAmountGreen - amountGreen
                let deltaBlue = currentAmountBlue - amountBlue
                
                if abs(deltaRed) < tolerance && abs(deltaGreen) < tolerance && abs(deltaBlue) < tolerance {
                    if currentAmount > amountForSelectedCrayon {
                        selectedCrayon = Crayon(rawValue: crayon.hex)!
                        amountForSelectedCrayon = currentAmount
                    }
                }
            }
            print("\(selectedCrayon) : \(selectedCrayon.rawValue)")
            return selectedCrayon
        }
        
        static func getCrayon(uicolor color: UIColor) -> Crayon {
            return getCrayon(UIColor.getHexValue(color))
        }
    }

}



