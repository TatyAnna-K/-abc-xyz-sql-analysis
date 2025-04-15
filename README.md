# Проект: Анализ ассортимента интернет-магазина бытовой химии с использованием методов ABC и XYZ

## Описание бизнес-задачи

Интернет-магазин бытовой химии, работающий на рынке уже 10 лет, сталкивается с проблемами неэффективного управления запасами и ассортиментом. Из-за избыточных запасов некоторых товаров замедляется оборот капитала, растут расходы на хранение, а дефицит популярных позиций приводит к упущенным продажам и недовольству клиентов.

## Цель проекта

Оптимизация ассортимента магазина путем классификации товаров по степени важности и стабильности спроса, чтобы снизить издержки и повысить эффективность операций.

## Методы анализа

Использовала методы **ABC** и **XYZ** для разделения товаров на категории по их значимости и предсказуемости спроса соответственно. Для **ABC-анализа** выбрала показатели количества проданных единиц, выручки и прибыли, а для **XYZ-анализа** — стабильность спроса.

## Как я решала эту задачу

1. Загрузила синтетические данные за первое полугодие 2024 года в PostgreSQL. Данные включают таблицы продуктов и заказов. Файлы с данными (*orders.csv*, *products.csv*) прикрепила ниже.

2. Выполнила классификацию товаров методами **ABC** и **XYZ**.

3. Построила отчеты по каждому методу отдельно и сделала комбинацию результатов для получения полной картины.

## Код

Код можно посмотреть по ссылке: [abc.xyx.sql](./scripts/abc.xyz.sql) 

## Основные результаты

* **ABC-анализ**: выявила, что 51% всех товаров приносят основную часть прибыли, тогда как остальные продукты требуют дополнительного внимания.
* **XYZ-анализ**: определила, что большинство товаров характеризуются нестабильными продажами, что требует тщательного планирования закупок.
* **Комбинационный ABC/XYZ-анализ**: показала, что большая часть товаров относится к группам с высоким уровнем продаж и нестабильным спросом, что создает риски для бизнеса.

## Рекомендации

По результатам проведенного анализа каждой группе товаров были предложены рекомендации для повышения их группы. Рекомендации можно посмотреть на вкладке **«Выводы»** в файле Excel **«ABC_XYZ анализ»**, который я прикрепила ниже.

Общие рекомендации:
1. Увеличить долю товаров с устойчивым спросом (**группа AX**), одновременно сокращая ассортимент товаров с низкой популярностью и непредсказуемостью.
2. Регулярно обновлять классификацию ассортимента для отслеживания изменений в потребительских предпочтениях.
3. Рассмотреть возможность внедрения автоматизированных систем управления запасами для повышения точности прогнозирования спроса.
4. Проводить регулярные акции и скидочные программы для стимулирования продаж менее востребованных товаров.
5. Пересмотреть условия сотрудничества с поставщиками для снижения затрат на логистику и хранение.

## Выводы

Результаты анализа показали, что текущее распределение ассортимента магазина не соответствует принципу Парето, где 20% товаров должны приносить 80% прибыли. Оптимизация ассортимента позволит значительно сократить издержки и повысить конкурентоспособность магазина.
