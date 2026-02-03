/*  ТЕСТОВИЙ ПРОЕКТ
  Автор: [Bohdan Padalka]
  Об'єкт: Аналіз GGR, ризиків та поведінки гравців (EPL Data)
*/

-- 1. Основні показники (KPI) компанії
-- Рахуємо "брудний" прибуток (GGR) 
SELECT 
    sum(stake) as stakes,                     -- Скільки всього поставили
    sum(payout) as sum_payouts,                    -- Скільки виплатили гравцям
    sum(stake) - sum(payout) as GGR            -- Наш валовий дохід
FROM bets_placed;

-----------------------------------------------------------

-- 2. Аналіз прибутковості матчів
-- Шукаємо топ-10 матчів, на яких контора заробила найбільше
SELECT 
    m.home_team, 
    m.away_team,
    count(b.bet_id) as total_bets,
    sum(b.stake) - sum(b.payout) as match_ggr
FROM matches m
JOIN bets_placed b ON m.match_id = b.match_id
GROUP BY 1, 2
ORDER BY match_ggr DESC
LIMIT 10;

-----------------------------------------------------------

-- 3. Антифрод та ризики
-- Шукаємо гравців з підозріло високим виграшем (RTP > 110%)
-- Це допомагає виявити "шарпів" (професіоналів) або арбітражників
SELECT 
    user_id,
    count(*) as bets_count,
    sum(stake) as total_staked,
    ROUND((sum(payout) / sum(stake)) * 100, 1) as rtp_pct
FROM bets_placed
GROUP BY 1
HAVING bets_count > 15 AND rtp_pct > 110
ORDER BY rtp_pct DESC;

-----------------------------------------------------------

-- 4. Популярність ринків 
-- Дивимось, куди гравці заливають найбільше грошей
SELECT 
    bet_type,
    count(*) as frequency,
    sum(stake) as total_volume,
    avg(odds) as avg_odds
FROM bets_placed
GROUP BY 1
ORDER BY total_volume DESC;

-----------------------------------------------------------

-- 5. Популярність команд серед гравців
-- Дивимось, на чиї матчі люди ставлять найбільше грошей
-- Це допомагає зрозуміти, які команди генерують основний оборот
SELECT 
    m.home_team, 
    count(b.bet_id) as bets_count,        -- Кількість ставок
    sum(b.stake) as total_money_staked,   -- Загальна сума грошей
    avg(b.stake) as average_bet           -- Середній чек ставки
FROM matches m
JOIN bets_placed b ON m.match_id = b.match_id
GROUP BY 1
ORDER BY total_money_staked DESC
LIMIT 10;