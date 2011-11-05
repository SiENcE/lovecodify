Font = class()

-- - The Hershey Fonts were originally created by Dr.
-- A. V. Hershey while working at the
-- U. S. National Bureau of Standards.

-- Useful Links:
-- http://emergent.unpythonic.net/software/hershey
-- http://paulbourke.net/dataformats/hershey/

-- Re-encoding of font information and other shenanigans
-- by Tom Bortels bortels@gmail.com November 2011
-- all rights reversed (Hail Eris!)

-- "If I have seen a little further it is by standing
-- on the shoulders of Giants."
-- Isaac Newton

function Font:init()
   -- font data - 2 decimal character # of points,
   -- followed by 2*points of point data
   -- 9->-9, 8-<-8, ... 1->-1, 0->0, A->1, B->2, ... Z->26
   self.code = "9876543210ABCDEFGHIJKLMNOPQRSTUVWXYZ"
   -- this is the Hershey Roman Simplex font for ascii 32-127
   self.fontdata =
      "00160810EUEG11EBDAE0FAEB0516DUDN11LULN1121KYD711QYJ711DLRL11"
   .. "CFQF2620HYH411LYL411QROTLUHUETCRCPDNEMGLMJOIPHQFQCOAL0H0EACC"
   .. "3124UUC011HUJSJQIOGNENCPCRDTFUHUJTMSPSSTUU11QGOFNDNBP0R0TAUC"
   .. "UESGQG3426WLWMVNUNTMSKQFOCMAK0G0EADBCDCFDHEILMMNNPNRMTKUITHR"
   .. "HPIMKJPCRAT0V0WAWB0710ESDTEUFTFREPDO1014KYIWGTEPDKDGEBG2I5K7"
   .. "1014CYEWGTIPJKJGIBG2E5C70816HUHI11CRML11MRCL0526MRM011DIVI08"
   .. "10FAE0DAEBFAF1E3D40226DIVI0510EBDAE0FAEB0222TYB71720IUFTDQCL"
   .. "CIDDFAI0K0NAPDQIQLPQNTKUIU0420FQHRKUK01420DPDQESFTHULUNTOSPQ"
   .. "POOMMJC0Q01520EUPUJMMMOLPKQHQFPCNAK0H0EADBCD0620MUCGRG11MUM0"
   .. "1720OUEUDLEMHNKNNMPKQHQFPCNAK0H0EADBCD2320PROTLUJUGTEQDLDGEC"
   .. "GAJ0K0NAPCQFQGPJNLKMJMGLEJDG0520QUG011CUQU2920HUETDRDPENGMKL"
   .. "NKPIQGQDPBOAL0H0EADBCDCGDIFKILMMONPPPROTLUHU2320PNOKMIJHIHFI"
   .. "DKCNCODRFTIUJUMTORPNPIODMAJ0H0EADC1110ENDMELFMEN11EBDAE0FAEB"
   .. "1410ENDMELFMEN11FAE0DAEBFAF1E3D40324TRDIT00526DLVL11DFVF0324"
   .. "DRTID02018CPCQDSETGUKUMTNSOQOONMMLIJIG11IBHAI0JAIB5527RMQOOP"
   .. "LPJOINHKHHIFKENEPFQH11LPJNIKIHJFKE11RPQHQFSEUEWGXJXLWOVQTSRT"
   .. "OULUITGSEQDOCLCIDFEDGBIAL0O0RATBUC11SPRHRFSE0818IUA011IUQ011"
   .. "DGNG2321DUD011DUMUPTQSRQROQMPLMK11DKMKPJQIRGRDQBPAM0D01821RP"
   .. "QROTMUIUGTERDPCMCHDEECGAI0M0OAQCRE1521DUD011DUKUNTPRQPRMRHQE"
   .. "PCNAK0D01119DUD011DUQU11DKLK11D0Q00818DUD011DUQU11DKLK2221RP"
   .. "QROTMUIUGTERDPCMCHDEECGAI0M0OAQCRERH11MHRH0822DUD011RUR011DK"
   .. "RK0208DUD01016LULEKBJAH0F0DACBBEBG0821DUD011RUDG11ILR00517DU"
   .. "D011D0P01124DUD011DUL011TUL011TUT00822DUD011DUR011RUR02122IU"
   .. "GTERDPCMCHDEECGAI0M0OAQCRESHSMRPQROTMUIU1321DUD011DUMUPTQSRQ"
   .. "RNQLPKMJDJ2422IUGTERDPCMCHDEECGAI0M0OAQCRESHSMRPQROTMUIU11LD"
   .. "R21621DUD011DUMUPTQSRQROQMPLMKDK11KKR02020QROTLUHUETCRCPDNEM"
   .. "GLMJOIPHQFQCOAL0H0EACC0516HUH011AUOU1022DUDFECGAJ0L0OAQCRFRU"
   .. "0518AUI011QUI01124BUG011LUG011LUQ011VUQ00520CUQ011QUC00618AU"
   .. "IKI011QUIK0820QUC011CUQU11C0Q01114DYD711EYE711DYKY11D7K70214"
   .. "0UN31114IYI711JYJ711CYJY11C7J71016FOHRJO11CLHQML11HQH0021602"
   .. "P20710FUETDRDPEOFPEQ1719ONO011OKMMKNHNFMDKCHCFDCFAH0K0MAOC17"
   .. "19DUD011DKFMHNKNMMOKPHPFOCMAK0H0FADC1418OKMMKNHNFMDKCHCFDCFA"
   .. "H0K0MAOC1719OUO011OKMMKNHNFMDKCHCFDCFAH0K0MAOC1718CHOHOJNLMM"
   .. "KNHNFMDKCHCFDCFAH0K0MAOC0812JUHUFTEQE011BNIN2219ONO2N5M6K7H7"
   .. "F611OKMMKNHNFMDKCHCFDCFAH0K0MAOC1019DUD011DJGMINLNNMOJO00808"
   .. "CUDTEUDVCU11DND01110EUFTGUFVEU11FNF3E6C7A70817DUD011NNDD11HH"
   .. "O00208DUD01830DND011DJGMINLNNMOJO011OJRMTNWNYMZJZ01019DND011"
   .. "DJGMINLNNMOJO01719HNFMDKCHCFDCFAH0K0MAOCPFPHOKMMKNHN1719DND7"
   .. "11DKFMHNKNMMOKPHPFOCMAK0H0FADC1719ONO711OKMMKNHNFMDKCHCFDCFA"
   .. "H0K0MAOC0813DND011DHEKGMINLN1717NKMMJNGNDMCKDIFHKGMFNDNCMAJ0"
   .. "G0DACC0812EUEDFAH0J011BNIN1019DNDDEAG0J0LAOD11ONO00516BNH011"
   .. "NNH01122CNG011KNG011KNO011SNO00517CNN011NNC00916BNH011NNH0F4"
   .. "D6B7A70817NNC011CNNN11C0N03914IYGXFWEUESFQGPHNHLFJ11GXFVFTGR"
   .. "HQIOIMHKDIHGIEICHAG0F2F4G611FHHFHDGBFAE1E3F5G6I70208DYD73914"
   .. "EYGXHWIUISHQGPFNFLHJ11GXHVHTGRFQEOEMFKJIFGEEECFAG0H2H4G611HH"
   .. "FFFDGBHAI1I3H5G6E72324CFCHDKFLHLJKNHPGRGTHUJ11CHDJFKHKJJNGPF"
   .. "RFTGUJUL"

   local i=1
   local c=32
   self.font = {}
   while (i < string.len(self.fontdata)) do
      local cs = string.char(c)
      self.font[cs] = {}
      local points = string.sub(self.fontdata, i, i+1)
      self.font[cs].points = points
      self.font[cs].char = cs
      self.font[cs].ascii = c
      self.font[cs].width = string.sub(self.fontdata, i+2, i+3)
      i = i + 4
      self.font[cs].data = string.sub(self.fontdata, i, i+points*2)
      i = i + points*2
      c = c + 1
   end
   i=-9
   self.decode = {}
   for c in self.code:gmatch"." do
      self.decode[c]=i
      i=i+1
   end
end

-- returns width in pixels of unscaled, strokeWidth(1) string
function Font:stringwidth(s)
   local x, l, i = 0, string.len(s)
   for i = 1, l do
      x = x + self.font[s:sub(i, i)].width
   end
end

-- draw a string at x,y (skipping offscreen draws)
function Font:drawstring(s, x, y)
   local l, i
   l = string.len(s)
   for i = 1, l do
      local c = s:sub(i, i)
      local w = self.font[c].width
      if ((x + w) >= 0) then
         x = x + (self:drawchar(c, x, y))
      else
         x = x + w -- skip offscreen left (but track position)
      end
      if (x > WIDTH) then break end -- skip offscreen right
   end
end

-- optimized draw string at x,y (old version for reference)
function Font:olddrawstring(s, x, y)
   local l, i
   l = string.len(s)
   for i = 1, l do
      x = x + (self:drawchar(string.sub(s, i, i), x, y))
   end
end

function Font:drawchar(c, x, y)
   local ax, ay, bx, by, minx, maxx = -1, -1, -1, -1, -1, -1
   local p, plot
   local ch = self.font[c]
   for p=1, ch.points do
      ax=bx
      ay=by
      bx=self.decode[ch.data:sub(p*2-1, p*2-1)]
      by=self.decode[ch.data:sub(p*2, p*2)]
      plot=true
      if ((ax==-1) and (ay==-1)) then plot=false end
      if ((bx==-1) and (by==-1)) then plot=false end
      if (plot) then
         line(x+ax, y+ay, x+bx, y+by)
      end
   end
   return ch.width -- for drawstring
end
