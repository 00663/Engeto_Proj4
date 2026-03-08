# Engeto SQL Projekt 4 - Analýza potravin a mezd
**Vypracoval:** Filip Hnilica

V tomto repozitáři najdete můj kód a výsledky čtvrtého projektu pro Engeto Datovou Akademii. Cílem bylo zanalyzovat, jak se u nás v průběhu let měnila dostupnost základních potravin v porovnání s průměrnými mzdami a HDP.

## Co jsem si pro analýzu připravil
Ze zdrojových dat jsem si vytvořil dvě hlavní tabulky:
1. **`t_filip_hnilica_project_SQL_primary_final`**: Tady jsem spojil data o mzdách a cenách potravin v ČR pro roky, které se překrývají (2006–2018). Všechno je zprůměrované za celý rok.
2. **`t_filip_hnilica_project_SQL_secondary_final`**: Doplňková data o HDP, GINI koeficientu a populaci dalších evropských států pro to samé období.

## Odpovědi na výzkumné otázky

**1. Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?**
Mzdy rozhodně nerostou pořád. Z dat je jasně vidět, že v některých letech a oborech průměrná mzda klesla (často to bylo kolem let 2009-2010 kvůli finanční krizi a pak v roce 2013), převážně v oborech těžby, ve státní sféře a pohostinství. Háček je ale v tom, že data ukazují jen nominální mzdy. Vůbec nezahrnují inflaci, takže nám neřeknou celou pravdu o reálné kupní síle. Mnohem lepší by bylo analyzovat růst reálné mzdy a ideálně pracovat s mediánem místo průměru. Průměr totiž dost zkreslují mzdy vysokopříjmových lidí, které rostou mnohem rychleji než to, co bere většina obyvatel.

**2. Kolik je možné si koupit litrů mléka a kg chleba za první a poslední srovnatelné období?**
* **2006:** Za průměrnou mzdu se dalo koupit zhruba 1312 kg chleba a 1465 litrů mléka.
* **2018:** Kupní síla šla nahoru, dalo se koupit cca 1365 kg chleba a 1669 litrů mléka. Vidíme že tyhle potraviny se tali během 12 let dostupnějí.

**3. Která kategorie potravin zdražuje nejpomaleji?**
Když porovnám roky 2006 a 2018, tak nejmenší procentuální nárůst měl "Cukr krystalový" -28% a "Rajská jablka" -23%, které jako jediné dva produkty zlevnily.

**4. Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?**
Ne. Podle dat nebyl v tomto období žádný rok, kde by průměrný růst cen potravin přeskočil růst mezd o víc než 10 procent. Výpočet je ale nutné brát s rezervou – je to jen obyčejný průměr pár vybraných produktů a neodráží to reálný "spotřební koš". Chybí nám informace o tom, jak velký podíl tyhle potraviny reálně tvoří v běžných výdajích domácností.

**5. Má výška HDP vliv na změny ve mzdách a cenách potravin?**
Ano, souvislost tam je. Když u nás rychleji rostlo HDP (třeba 2007 nebo 2015-2017), tak většinou hned ten samý nebo další rok víc rostly i mzdy a mírně i ceny potravin. Naopak v době propadu HDP (2009) se růst mezd zastavil. Opět jde ale o dost zjednodušený pohled, protože ignoruje inflaci a další makroekonomické ukazatele, jako je třeba celkové zadlužení.

## Co by šlo udělat líp (limity projektu)
Během práce s daty jsem narazil na pár věcí, které nejsou analyticky úplně čisté. Kvůli času jsem kód zjednodušil, abych splnil zadání, ale v praxi by to chtělo řešit jinak:

* **Zkreslení "průměru průměrů":** U celorepublikové mzdy dělám průměr z už spočítaných průměrů za jednotlivá odvětví. Vůbec přitom neberu v potaz, kolik v nich pracuje lidí (chybí váhy). Přesnější by bylo vytáhnout si rovnou celorepublikový průměr z původních dat (`industry_branch_code IS NULL`), který mi ale při spojování tabulek vypadl.
* **Průměrování absolutních cen:** U celkového zdražování dělám průměr rovnou z absolutních nominálních cen (míchám cenu za litr mléka s cenou za kilo masa), což pak zkresluje výslednou inflaci. Správně bych měl počítat procentuální změnu pro každý produkt zvlášť a z toho teprve dělat index.
* **Datová struktura:** Spojením mezd a cen jen přes společný rok vznikl obří kartézský součin (každé odvětví s každou potravinou). Zadání to sice plní, ale při dotazování na mzdy mě to donutilo používat `DISTINCT`, abych filtroval umělé duplicity.
