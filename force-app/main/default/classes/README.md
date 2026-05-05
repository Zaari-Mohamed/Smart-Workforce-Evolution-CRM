# 🧠 Smart Workforce Evolution CRM

> Salesforce-native AI platform that analyzes employees, predicts turnover risk, recommends personalized training paths, and tracks HR ROI — 100% free Developer Org.

![Salesforce](https://img.shields.io/badge/Salesforce-00A1E0?style=flat&logo=salesforce&logoColor=white)
![Einstein AI](https://img.shields.io/badge/Einstein%20AI-7F77DD?style=flat&logoColor=white)
![LWC](https://img.shields.io/badge/LWC-0C447C?style=flat&logoColor=white)
![Apex](https://img.shields.io/badge/Apex-1D9E75?style=flat&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=flat)
![Status](https://img.shields.io/badge/Status-In%20Progress-orange?style=flat)

---

## 💡 Concept

Most HR tools only recommend training. This system does **much more** :

| Without SWEC | With SWEC |
|---|---|
| Manual performance tracking | AI-powered risk scoring |
| Generic training catalog | Personalized recommendations |
| Reactive HR decisions | Predictive turnover alerts |
| No ROI measurement | Full training ROI tracking |

---

## 🔥 Key Features

- 📊 **Analyze** — Skills, performance, role, history per employee
- 🤖 **Predict** — Turnover risk score + skill gap detection (Einstein Discovery)
- 🎯 **Recommend** — Personalized training paths & promotion suggestions (Einstein Recommendations)
- 📈 **Track** — Formation ROI, career progression, manager alerts

---

## 🧱 Architecture

### Custom Objects
| Object | Role |
|---|---|
| `Employee__c` | Employee profile, scores, career stage |
| `Skill__c` | Current vs required skill levels |
| `Training__c` | Training catalog |
| `Evaluation__c` | Performance evaluations |
| `Recommendation__c` | AI-generated recommendations |

### Technologies
| Technology | Usage |
|---|---|
| Einstein Discovery | Turnover risk prediction |
| Einstein Recommendations | Personalized training matching |
| Apex + Triggers | Business logic & score calculation |
| Salesforce Flow | Auto-alerts & workflows |
| LWC | HR Dashboard & employee self-service |
| Dashboards | KPI tracking & ROI reporting |

---

## 🖥️ LWC Components

- `swecDashboardRH` — Executive HR dashboard with risk overview
- `swecEmployeeCard` — Smart employee card with AI scores & radar chart
- `swecMonParcours` — Employee self-service career view
- `swecManagerAlerts` — Real-time manager alert widget

---

## 📁 Project Structure



---

## 🚀 Getting Started

### Prerequisites
- [Salesforce CLI](https://developer.salesforce.com/tools/salesforcecli)
- [Git](https://git-scm.com)
- Free [Salesforce Developer Org](https://developer.salesforce.com/signup)

### Installation

```bash
# Clone the repo
git clone https://github.com/Zaari-Mohamed/smart-workforce-evolution-crm.git
cd smart-workforce-evolution-crm

# Authenticate your Developer Org
sf org login web --alias swec-dev

# Deploy to your org
sf project deploy start --target-org swec-dev
```

---

## 📅 Project Timeline

| Sprint | Theme | Status |
|---|---|---|
| S1 — Week 1 | Setup & Custom Objects | 🔄 In progress |
| S2 — Week 2 | Data & Relations | ⏳ Planned |
| S3 — Week 3 | Einstein Discovery | ⏳ Planned |
| S4 — Week 4 | Einstein Recommendations | ⏳ Planned |
| S5 — Week 5 | Flows & Alerts | ⏳ Planned |
| S6 — Week 6 | Apex & Logic | ⏳ Planned |
| S7 — Week 7 | LWC & UI | ⏳ Planned |
| S8 — Week 8 | Dashboards & UAT | ⏳ Planned |

---

## 👤 Author

**Mohamed Zaari**
- GitHub : [@Zaari-Mohamed](https://github.com/Zaari-Mohamed)

---

## 📄 License

MIT — free to use for educational and portfolio purposes.