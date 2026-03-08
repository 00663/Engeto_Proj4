# Engeto SQL Projekt 4 - Analýza potravin a mezd

Tento repozitář obsahuje SQL skripty a výsledky čtvrtého projektu do Engeto Datové Akademie. Cílem bylo analyzovat dostupnost základních potravin v ČR v závislosti na průměrných mzdách a HDP.

## Vytvořené tabulky
Pro analýzu byly z původních dat vytvořeny dvě souhrnné tabulky:
1. **`t_filip_hnilica_project_SQL_primary_final`**: Obsahuje sjednocená data o průměrných mzdách a cenách potravin pro ČR za společné období (roky 2006–2018). Data jsou ročně zprůměrována.
2. **`t_filip_hnilica_project_SQL_secondary_final`**: Obsahuje makroekonomické ukazatele (HDP, GINI, populace) pro evropské státy ve stejném období.

## Odpovědi na výzkumné otázky

**1. Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?**
Mzdy nerostou neustále. Z dat vyplývá, že v některých letech a odvětvích docházelo k meziročnímu poklesu průměrné mzdy (často například v období kolem let 2009-2010 v důsledku finanční krize, nebo v roce 2013). 

**2. Kolik je možné si koupit litrů mléka a kg chleba za první a poslední srovnatelné období?**
* **2006:** Za průměrnou mzdu bylo možné koupit cca 1435 kg chleba a 1409 litrů mléka.
* **2018:** Kupní síla vzrostla, bylo možné koupit cca 1342 kg chleba a 1641 litrů mléka (přesná čísla vycházejí z SQL dotazu č. 2).

**3. Která kategorie potravin zdražuje nejpomaleji?**
Při srovnání let 2006 a 2018 se ukázalo, že nejnižší procentuální nárůst cen měla kategorie "Cukr krystalový", případně "Rajská jablka" (některé položky dokonce mírně zlevnily). 

**4. Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?**
Ne. Z analýzy meziročních průměrů nevyplývá, že by v jakémkoliv roce mezi lety 2006 a 2018 průměrný růst cen potravin převýšil růst mezd o více než 10 procentních bodů. 

**5. Má výška HDP vliv na změny ve mzdách a cenách potravin?**
Ano, korelace je patrná. V letech, kdy ČR zaznamenala silnější růst HDP (např. 2007 nebo 2015-2017), zpravidla v témže nebo následujícím roce následoval i znatelnější růst průměrných mezd a mírný růst cen potravin. Naopak v letech poklesu HDP (2009) se růst mezd zastavil nebo zpomalil.
