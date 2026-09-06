/*M!999999\- enable the sandbox mode */ 
-- MariaDB dump 10.19  Distrib 10.11.13-MariaDB, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: career_platform
-- ------------------------------------------------------
-- Server version	10.11.13-MariaDB-0ubuntu0.24.04.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `accounting_settings`
--

DROP TABLE IF EXISTS `accounting_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `accounting_settings` (
  `id` tinyint(4) NOT NULL DEFAULT 1,
  `hold_days` int(11) NOT NULL DEFAULT 7,
  `platform_fee_pct` decimal(5,2) NOT NULL DEFAULT 10.00,
  `processing_fee_pct` decimal(5,2) NOT NULL DEFAULT 2.90,
  `processing_fee_fixed` decimal(10,2) NOT NULL DEFAULT 0.30,
  `min_payout_amount` decimal(12,2) NOT NULL DEFAULT 20.00,
  `currency` char(3) NOT NULL DEFAULT 'USD',
  `auto_release_on_completion` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accounting_settings`
--

LOCK TABLES `accounting_settings` WRITE;
/*!40000 ALTER TABLE `accounting_settings` DISABLE KEYS */;
INSERT INTO `accounting_settings` VALUES
(1,7,20.00,1.90,0.40,20.00,'USD',0,'2025-09-07 18:46:29','2025-09-13 14:35:04');
/*!40000 ALTER TABLE `accounting_settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_revoked_tokens`
--

DROP TABLE IF EXISTS `auth_revoked_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `auth_revoked_tokens` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `token_hash` char(64) NOT NULL,
  `user_id` bigint(20) unsigned DEFAULT NULL,
  `expires_at` datetime NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `token_hash` (`token_hash`),
  KEY `expires_at` (`expires_at`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_revoked_tokens`
--

LOCK TABLES `auth_revoked_tokens` WRITE;
/*!40000 ALTER TABLE `auth_revoked_tokens` DISABLE KEYS */;
/*!40000 ALTER TABLE `auth_revoked_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `blog_categories`
--

DROP TABLE IF EXISTS `blog_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `blog_categories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(120) NOT NULL,
  `slug` varchar(160) NOT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `slug` (`slug`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `blog_categories`
--

LOCK TABLES `blog_categories` WRITE;
/*!40000 ALTER TABLE `blog_categories` DISABLE KEYS */;
INSERT INTO `blog_categories` VALUES
(1,'Career Development','career-development',1,'2025-09-26 21:29:49'),
(2,'Interviewing','interviewing',1,'2025-09-26 21:30:04'),
(3,'Résumé & Portfolio','r-sum-portfolio',1,'2025-09-26 21:30:16'),
(4,'Learning Paths','learning-paths',1,'2025-09-26 21:30:47'),
(5,'Tech & Tools','tech-tools',1,'2025-09-26 21:31:03'),
(6,'Entrepreneurship','entrepreneurship',1,'2025-09-26 21:31:19'),
(7,'Case Studies & Success','case-studies-success',1,'2025-09-26 21:31:37'),
(8,'Industry Insights','industry-insights',1,'2025-09-26 21:31:52'),
(9,'Freelancing & Consulting','freelancing-consulting',1,'2025-09-26 21:32:05'),
(10,'Leadership & Management','leadership-management',1,'2025-09-26 21:32:21');
/*!40000 ALTER TABLE `blog_categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `blog_comments`
--

DROP TABLE IF EXISTS `blog_comments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `blog_comments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `blog_id` int(11) NOT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `author_name` varchar(100) DEFAULT NULL,
  `author_email` varchar(190) DEFAULT NULL,
  `body` text NOT NULL,
  `status` enum('approved','pending','spam') NOT NULL DEFAULT 'pending',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_blog_status_created` (`blog_id`,`status`,`created_at`),
  KEY `idx_parent` (`parent_id`),
  CONSTRAINT `fk_cmt_post` FOREIGN KEY (`blog_id`) REFERENCES `blog_posts` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `blog_comments`
--

LOCK TABLES `blog_comments` WRITE;
/*!40000 ALTER TABLE `blog_comments` DISABLE KEYS */;
INSERT INTO `blog_comments` VALUES
(1,2,NULL,NULL,'mustafizur142','mustafizur142@gmail.com','Awesome','pending','2025-09-28 10:10:42',NULL);
/*!40000 ALTER TABLE `blog_comments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `blog_post_categories`
--

DROP TABLE IF EXISTS `blog_post_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `blog_post_categories` (
  `blog_id` int(11) NOT NULL,
  `category_id` int(11) NOT NULL,
  PRIMARY KEY (`blog_id`,`category_id`),
  KEY `idx_bpc_blog` (`blog_id`),
  KEY `idx_bpc_cat` (`category_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `blog_post_categories`
--

LOCK TABLES `blog_post_categories` WRITE;
/*!40000 ALTER TABLE `blog_post_categories` DISABLE KEYS */;
INSERT INTO `blog_post_categories` VALUES
(1,1),
(1,4);
/*!40000 ALTER TABLE `blog_post_categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `blog_post_tags`
--

DROP TABLE IF EXISTS `blog_post_tags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `blog_post_tags` (
  `blog_id` int(11) NOT NULL,
  `tag_id` int(11) NOT NULL,
  PRIMARY KEY (`blog_id`,`tag_id`),
  KEY `idx_bpt_blog` (`blog_id`),
  KEY `idx_bpt_tag` (`tag_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `blog_post_tags`
--

LOCK TABLES `blog_post_tags` WRITE;
/*!40000 ALTER TABLE `blog_post_tags` DISABLE KEYS */;
INSERT INTO `blog_post_tags` VALUES
(1,1),
(1,2),
(1,3);
/*!40000 ALTER TABLE `blog_post_tags` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `blog_posts`
--

DROP TABLE IF EXISTS `blog_posts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `blog_posts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `author_id` int(11) NOT NULL,
  `title` varchar(200) NOT NULL,
  `slug` varchar(220) NOT NULL,
  `excerpt` varchar(320) DEFAULT NULL,
  `content_html` longtext DEFAULT NULL,
  `cover_image` varchar(512) DEFAULT NULL,
  `status` enum('draft','pending','published','rejected','archived') NOT NULL DEFAULT 'draft',
  `visibility` enum('public','unlisted','private') NOT NULL DEFAULT 'public',
  `is_featured` tinyint(1) NOT NULL DEFAULT 0,
  `allow_comments` tinyint(1) NOT NULL DEFAULT 1,
  `reject_reason` text DEFAULT NULL,
  `meta_title` varchar(160) DEFAULT NULL,
  `meta_description` varchar(180) DEFAULT NULL,
  `meta_keywords` varchar(255) DEFAULT NULL,
  `canonical_url` varchar(255) DEFAULT NULL,
  `og_image` varchar(512) DEFAULT NULL,
  `schema_json` mediumtext DEFAULT NULL,
  `read_time_minutes` smallint(6) DEFAULT NULL,
  `published_at` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `slug` (`slug`),
  KEY `idx_blog_status` (`status`),
  KEY `idx_blog_author` (`author_id`),
  KEY `idx_blog_published_at` (`published_at`),
  FULLTEXT KEY `ft_blog_title_excerpt` (`title`,`excerpt`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `blog_posts`
--

LOCK TABLES `blog_posts` WRITE;
/*!40000 ALTER TABLE `blog_posts` DISABLE KEYS */;
INSERT INTO `blog_posts` VALUES
(1,4,'How to Choose the Right Mentor in 2025: A 7-Step Playbook','how-to-choose-the-right-mentor-in-2025-a-7-step-playbook','A crisp, 7-step process to find the right mentor for your goals—plus outreach templates and red flags to avoid.','<h2>How to Choose the Right Mentor in 2025: A 7-Step Playbook</h2><p><em>Good mentorship compresses years of trial and error into months of progress.</em></p><p> The challenge isn’t finding <strong>a</strong> mentor—it’s finding the <strong>right</strong> mentor for <strong>your</strong> goals. Use this weekend-friendly playbook.</p><h3>Step 1 — Write a one-paragraph goal</h3><p>Define success in 4–5 sentences. Include timeframe, constraints, and what <strong>you</strong> will do.</p><p> <strong>Example:</strong> “In 90 days I want to move from QA Analyst to SDET. I can invest 5–7 hrs/week. I’ll ship two portfolio projects and practice interviews weekly.”</p><h3>Step 2 — Pick the <em>stage-fit</em> mentor</h3><ul><li><strong>Breaking in:</strong> hands-on practitioners doing the job today.</li><li><strong>Leveling up:</strong> senior ICs who’ve solved your exact bottleneck.</li><li><strong>Leadership:</strong> managers with hiring + team-building experience.</li></ul><h3>Step 3 — Score candidates (15-minute matrix)</h3><p>Score 1–5 on:</p><ol><li><strong>Relevant wins:</strong> shipped products, roles, industries like yours</li><li><strong>Teaching signals:</strong> blogs, talks, code reviews, templates</li><li><strong>Availability:</strong> cadence that matches your timeline</li><li><strong>Style match:</strong> direct vs. supportive; async vs. live</li></ol><h3>Step 4 — Run a 25-minute chemistry call</h3><p>Ask:</p><ul><li>“What would a strong 60–90 day plan look like for my goal?”</li><li>“Where do mentees usually get stuck—and how do you unblock them?”</li><li>“What does success look like and how will we measure it?”</li></ul><h3>Step 5 — Red flags</h3><ul><li>Vague answers; no artifacts (rubrics, checklists, templates)</li><li>Guarantees about promotions/offers</li><li>Overbooked calendars or early reschedules</li></ul><h3>Step 6 — Confirm the plan in writing</h3><p>Send a short recap with cadence, deliverables, and success metrics.</p><h3>Step 7 — Be a great mentee</h3><ul><li>Arrive with a bullet agenda + completed homework</li><li>Keep one running doc for decisions and next steps</li><li>Share outcomes (good or bad) within 24–48 hours</li></ul><p><br></p>','/uploads/blogs/covers/1758922703230-business-ida.jpg','published','public',0,1,NULL,NULL,NULL,NULL,NULL,'/uploads/blogs/covers/1758922703230-business-ida.jpg',NULL,1,'2025-09-26 21:38:48','2025-09-26 21:38:22','2025-09-26 21:38:48'),
(2,6,'Why Clients Complain About Coaching Programs & What Coaching Experts Can Do About It','why-clients-complain-about-coaching-programs-what-coaching-experts-can-do-about-it',NULL,'<h2><strong>Introduction: The Trust Problem</strong></h2><p><br></p><p>The coaching industry is booming, projected to exceed <strong>$27.5 billion by 2026</strong>. But behind the glossy marketing, many clients walk away disappointed.</p><p>On Reddit and professional forums like LinkedIn, common complaints emerge:</p><ul><li>Coaching is too generic</li><li>Programs are overpriced</li><li>Results are inconsistent</li><li>Accountability is lacking</li></ul><p><br></p><p>Worse yet, industry data shows <strong>82% of coaching businesses fail within two years</strong>, and <strong>47% of people distrust life coaches.</strong> Clearly, something’s broken.</p><p><br></p><p>In this post, Prosfata Inc. unpacks the five biggest reasons clients complain about coaching programs and offers a practical framework for avoiding these pitfalls when choosing a coach in 2025.</p><h2><br></h2><h2><strong>The Top Five Biggest Reasons Clients Complain About Coaching Programs</strong></h2><h3><br></h3><h3><strong>1. Generic and Ineffective Advice</strong></h3><p>One of the loudest client complaints is that coaching advice feels generic, repetitive, and uninspired.</p><p><strong>“Why do most coaching sessions feel like generic advice?”</strong></p><p><strong>“How can I tell if a coach is just regurgitating online content?”</strong></p><p>The issue: Many coaches rely on pre-packaged scripts and “mindset” clichés (“send 100 emails,” “change your mindset”) instead of personalized, context-specific strategies. Group programs amplify the problem; one-size-fits-all advice often fails to translate into measurable change.</p><h4><br></h4><h4><strong>Why It Happens — With Data</strong></h4><ul><li><strong>High failure and turnover in coaching businesses:</strong> Over 80% of coaching practices fail within their early years — a signal that many can’t sustain value or retain clients. Struggling coaches often cut corners or recycle content.</li><li><strong>Lack of specialization and real-world experience:</strong> The coaching market is wide open and unregulated. Many new coaches enter without domain expertise or a defined niche.</li><li><strong>Weak client satisfaction mechanisms:</strong> In other industries, a CSAT (Customer Satisfaction Score) above 70% is healthy. In coaching, many programs don’t measure CSAT or NPS at all, meaning “generic” programs survive behind polished marketing.</li></ul><h4><br></h4><h4><strong>Suggestions &amp; Data Gaps to Fill</strong></h4><ul><li>Coaching-specific CSAT/NPS surveys.</li><li>Retention rates in coaching programs (how many clients renew vs. churn).</li><li>Benchmark comparisons across niches (executive vs. life coaching).</li></ul><p><br></p><p><a href=\"https://prosfata.space/\" rel=\"noopener noreferrer\" target=\"_blank\"><strong>Prosfata Insight</strong></a><strong>:</strong></p><p>A legitimate coaching program should deliver <strong>customized sessions tailored to your industry, business model, and personal goals.</strong> At Prosfata, we:</p><ul><li>Build <strong>custom diagnostics</strong> before prescribing frameworks.</li><li>Design <strong>feedback loops</strong> into engagements (monthly surveys, sentiment scoring, dashboards).</li><li>Detect “generic advice fatigue” early and <strong>course-correct</strong>.</li></ul><h3><br></h3><h3><strong>2. High Costs and Scam-Like Practices</strong></h3><p>Another major frustration? The price tag.</p><p>The global coaching industry was worth <strong>$20 billion in 2023</strong> and is projected to hit <strong>$27.5 billion by 2026</strong>. Yet, only ~10–20% of clients report clear ROI from expensive programs (varies by niche). High-ticket coaching often charges <strong>$200–$10,000+</strong>, with some executive programs reaching <strong>$100,000.</strong></p><ul><li>“Why are coaching programs so expensive?”</li><li>“How do I know if a high-ticket program is worth it?”</li><li>“Are free discovery calls just sales pitches?”</li></ul><p><br></p><p><strong>The issue:</strong> When pricing is inflated without clear ROI, clients feel exploited. Many discover the “program” is recycled motivational content, upsold aggressively. Some are even pushed into credit card debt to join.</p><p><br></p><p><a href=\"https://prosfata.space/\" rel=\"noopener noreferrer\" target=\"_blank\"><strong>Prosfata Insight</strong></a><strong>:</strong></p><p>Before investing, demand <strong>transparent deliverables:</strong> What outcomes are being tracked? How will ROI be measured? At Prosfata, we help professionals build <strong>pricing models grounded in evidence and accountability</strong>, not hype.</p><h3><br></h3><h3><strong>3. Inconsistent Quality and Lack of Standards</strong></h3><p>Coaching is often described as the <strong>Wild West of professional services</strong>.</p><p>A 2022 ICF survey found only <strong>39% of coaches hold ICF credentials.</strong> Yet <strong>82% of clients say certification increases trust</strong> — showing the gap between expectations and reality.</p><ul><li>“Do coaching certifications matter in 2025?”</li><li>“Why is coaching unregulated?”</li><li>“Can anyone call themselves a coach?”</li></ul><p><br></p><p><strong>The reality:</strong> Unlike medicine, law, or therapy, coaching has no regulatory board. This creates massive variation in quality: some coaches are seasoned experts, others are brand-new.</p><p><br></p><p><a href=\"https://prosfata.space/\" rel=\"noopener noreferrer\" target=\"_blank\"><strong>Prosfata Insight</strong></a><strong>:</strong></p><p>The best coaches combine <strong>certification, domain expertise, and lived experience.</strong> Clients should look for:</p><ul><li>Evidence of outcomes (case studies, testimonials).</li><li>Clear industry expertise.</li><li>Transparent practices — not just a big social following.</li></ul><h3><br></h3><h3><strong>4. Lack of Accountability and Follow-Through</strong></h3><p>Even when coaching starts strong, clients often complain about poor follow-through.</p><p>A Harvard Business Review study found only <strong>35% of coaching programs include measurable goals.</strong> Less than 20% track outcomes post-engagement. Clients with structured accountability are <strong>2.5x more likely</strong> to report satisfaction.</p><ul><li>“Why do some coaches never check on progress?”</li><li>“Should coaches be responsible for client results?”</li><li>“Why do I feel dependent on my coach for motivation?”</li></ul><p>The issue: Many programs fail to build <strong>accountability systems</strong>. Without KPIs or dashboards, sessions become “talk therapy” without results.</p><p><br></p><p><a href=\"https://prosfata.space/\" rel=\"noopener noreferrer\" target=\"_blank\"><strong>Prosfata Insight</strong></a><strong>:</strong></p><p>A strong coaching program includes:</p><ul><li><strong>Progress dashboards</strong></li><li><strong>KPI tracking</strong></li><li><strong>CRM integrations</strong></li><li>This ensures accountability between sessions and proves ROI.</li></ul><h3><br></h3><h3><strong>5. Trust and Perception Problems</strong></h3><p>Finally, the coaching industry faces a <strong>trust deficit</strong>.</p><p>A 2021 YouGov survey found <strong>47% of people don’t trust life coaches.</strong> Scandals — fake testimonials, plagiarized content, false promises — reinforce skepticism.</p><ul><li><strong>“</strong>Why don’t people trust coaches?”</li><li>“How do I separate good coaches from fake gurus?”</li><li>“Why do so many coaches feel like influencers?”</li></ul><p><br></p><p><strong>The issue:</strong> With no regulation and inflated marketing, many clients feel coaches are <strong>more focused on branding than results.</strong></p><p><br></p><p><a href=\"https://prosfata.space/\" rel=\"noopener noreferrer\" target=\"_blank\"><strong>Prosfata Insight</strong></a><strong>:</strong></p><p>Trust comes from <strong>evidence, not aesthetics.</strong> Ask:</p><ul><li>“Can you show me results with clients like me?”</li><li>“Do you have transparent case studies and pricing?”</li></ul><h2><br></h2><h2><strong>Our Recommendation for Choosing a Coach</strong></h2><h3><strong>The REAL Checklist (Prosfata’s Framework)</strong></h3><p>To help professionals cut through hype, Prosfata recommends the <strong>REAL framework:</strong></p><ul><li><strong>R – Relevance:</strong> Does the coach’s expertise align with your goals/industry?</li><li><strong>E – Evidence:</strong> Do they provide case studies or measurable outcomes?</li><li><strong>A – Accountability:</strong> Do they track ROI &amp; progress?</li><li><strong>L – Longevity:</strong> Will methods last beyond the program?</li></ul><h2><br></h2><h2><strong>Case Example: From Generic Advice to Customized Growth</strong></h2><p>A mid-career consultant came to Prosfata frustrated after spending <strong>$3,000</strong> on a “mindset” program. We helped restructure with:</p><ul><li>Personalized framework informed by his <strong>industry background.</strong></li><li><strong>CRM system</strong> to track leads and progress.</li><li><strong>KPIs</strong> that proved ROI within 90 days.</li></ul><p><strong>Result:</strong> He recovered his investment and scaled sustainably with measurable coaching impact.</p><h2><br></h2><h2><strong>People Also Ask (FAQ)</strong></h2><ol><li><strong>Is coaching worth it in 2025, or just a scam? </strong> It depends. Coaching works when it’s personalized, accountable, and evidence-based.</li><li><strong>How do I know if my coach is qualified? </strong> Look for outcomes, case studies, and domain expertise — not just certifications.</li><li><strong>Why do some programs cost $10,000+? </strong> Often branding/hype. Always ask for ROI justification.</li><li><strong>What red flags should I watch for? </strong> Aggressive sales tactics, vague deliverables, fake testimonials, no measurable success metrics.</li><li><strong>How do I track if coaching is working? </strong> Use KPIs, dashboards, and milestones. Prosfata builds these into every program.</li></ol><h2><br></h2><h2><strong>Conclusion: Coaching Doesn’t Have to Disappoint</strong></h2><p>Coaching can deliver transformative results — but <strong>generic advice, inflated costs, inconsistent quality, poor accountability, and trust issues</strong> remain rampant.</p><p>The data confirms it:</p><ul><li><strong>80%+ of coaching businesses fail early.</strong></li><li><strong>47% of the public distrusts coaching.</strong></li><li><strong>Only 35% of programs measure outcomes.</strong></li></ul><p><br></p><p><strong>Prosfata Inc. is changing this.</strong> We help professionals build <strong>evidence-based, tech-enabled, accountable coaching programs</strong> that deliver ROI — not empty promises.</p>','/uploads/blogs/covers/1759002134794-coachign-experts-coachign-busineses-icf-certified-coaches.png','published','public',0,1,NULL,NULL,NULL,NULL,NULL,'/uploads/blogs/covers/1759002134794-coachign-experts-coachign-busineses-icf-certified-coaches.png',NULL,6,'2025-09-27 19:45:32','2025-09-27 19:32:53','2025-09-27 19:45:32');
/*!40000 ALTER TABLE `blog_posts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `blog_tags`
--

DROP TABLE IF EXISTS `blog_tags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `blog_tags` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `slug` varchar(140) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `slug` (`slug`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `blog_tags`
--

LOCK TABLES `blog_tags` WRITE;
/*!40000 ALTER TABLE `blog_tags` DISABLE KEYS */;
INSERT INTO `blog_tags` VALUES
(1,'mentorship','mentorship','2025-09-26 21:38:22'),
(2,'career growth','career-growth','2025-09-26 21:38:22'),
(3,'goal setting','goal-setting','2025-09-26 21:38:22');
/*!40000 ALTER TABLE `blog_tags` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `categories`
--

DROP TABLE IF EXISTS `categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `categories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(120) NOT NULL,
  `slug` varchar(160) NOT NULL,
  `description` text DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `slug` (`slug`),
  UNIQUE KEY `uq_categories_name` (`name`),
  KEY `idx_categories_active` (`is_active`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categories`
--

LOCK TABLES `categories` WRITE;
/*!40000 ALTER TABLE `categories` DISABLE KEYS */;
INSERT INTO `categories` VALUES
(1,'Interview Prep 2','interview-prep-2','Mock interviews, feedback and drills',1,'2025-08-12 04:15:38'),
(2,'Web Development','web-development','HTML, CSS, JS, frameworks',1,'2025-08-16 15:11:39'),
(3,'Mobile Development','mobile-development','iOS, Android, cross-platform',1,'2025-08-16 15:11:39'),
(4,'Data Science','data-science','Analytics, Python, SQL, visualization',1,'2025-08-16 15:11:39'),
(5,'AI & Machine Learning','ai-ml','ML, DL, LLMs, MLOps',1,'2025-08-16 15:11:39'),
(6,'Cloud & DevOps','cloud-devops','AWS, Azure, GCP, CI/CD, containers',1,'2025-08-16 15:11:39'),
(7,'Cybersecurity','cybersecurity','Security, networks, ethical hacking',1,'2025-08-16 15:11:39'),
(8,'Programming Languages','programming-languages','JS/TS, Python, Java, C#, Go, Rust',1,'2025-08-16 15:11:39'),
(9,'Design & UX','design-ux','UI/UX, product design, Figma',1,'2025-08-16 15:11:39'),
(10,'Product Management','product-management','Roadmaps, discovery, delivery',1,'2025-08-16 15:11:39'),
(11,'Business & Entrepreneurship','business-entrepreneurship','Strategy, ops, startups',1,'2025-08-16 15:11:39'),
(12,'Marketing','marketing','Digital, content, SEO/SEM',1,'2025-08-16 15:11:39'),
(13,'Finance & Accounting','finance-accounting','FP&A, bookkeeping, investing',1,'2025-08-16 15:11:39'),
(14,'Career Development','career-development','Interviews, resumes, soft skills',1,'2025-08-16 15:11:39'),
(15,'Personal Productivity','personal-productivity','Time management, tools, habits',1,'2025-08-16 15:11:39'),
(16,'New Category 2','new-category-2','This is for demo',1,'2025-08-17 14:11:40');
/*!40000 ALTER TABLE `categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `chat_participants`
--

DROP TABLE IF EXISTS `chat_participants`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `chat_participants` (
  `chat_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `joined_at` datetime NOT NULL DEFAULT current_timestamp(),
  `typing` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`chat_id`,`user_id`),
  UNIQUE KEY `uq_chat_user` (`chat_id`,`user_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `fk_cp_chat` FOREIGN KEY (`chat_id`) REFERENCES `chats` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_cp_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chat_participants`
--

LOCK TABLES `chat_participants` WRITE;
/*!40000 ALTER TABLE `chat_participants` DISABLE KEYS */;
INSERT INTO `chat_participants` VALUES
(1,2,'2025-08-12 15:44:42',0),
(1,4,'2025-08-12 15:44:42',0),
(2,3,'2025-08-12 15:54:17',0),
(2,4,'2025-08-12 15:54:17',0),
(3,1,'2025-08-18 00:33:24',0),
(3,3,'2025-08-18 00:33:24',0),
(4,3,'2025-08-20 08:37:46',0),
(4,5,'2025-08-20 08:37:46',0),
(5,3,'2025-09-13 07:43:02',0),
(5,9,'2025-09-13 07:43:02',0),
(6,1,'2025-09-13 07:44:33',0),
(6,9,'2025-09-13 07:44:33',0),
(7,5,'2025-09-13 07:46:18',0),
(7,9,'2025-09-13 07:46:18',0),
(8,10,'2025-09-13 07:47:06',0),
(8,11,'2025-09-13 07:47:06',0),
(9,3,'2025-09-13 07:58:46',0),
(9,13,'2025-09-13 07:58:46',0),
(10,3,'2025-09-16 01:00:46',0),
(10,6,'2025-09-16 01:00:46',0),
(11,1,'2025-09-25 10:27:24',0),
(11,2,'2025-09-25 10:27:24',0),
(12,2,'2025-09-25 10:27:31',0),
(12,3,'2025-09-25 10:27:31',0),
(13,6,'2025-09-28 17:36:16',0),
(13,16,'2025-09-28 17:36:16',0),
(14,6,'2025-10-05 15:51:03',0),
(14,15,'2025-10-05 15:51:03',0),
(15,4,'2025-10-11 12:44:35',0),
(15,5,'2025-10-11 12:44:35',0),
(16,6,'2025-10-13 18:03:37',0),
(16,18,'2025-10-13 18:03:37',0);
/*!40000 ALTER TABLE `chat_participants` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `chat_reads`
--

DROP TABLE IF EXISTS `chat_reads`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `chat_reads` (
  `chat_id` bigint(20) NOT NULL,
  `user_id` bigint(20) NOT NULL,
  `last_read_message_id` bigint(20) NOT NULL DEFAULT 0,
  `read_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`chat_id`,`user_id`),
  KEY `idx_read_last` (`chat_id`,`last_read_message_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chat_reads`
--

LOCK TABLES `chat_reads` WRITE;
/*!40000 ALTER TABLE `chat_reads` DISABLE KEYS */;
INSERT INTO `chat_reads` VALUES
(1,2,56,'2025-09-28 07:09:53'),
(1,4,52,'2025-09-27 11:11:28'),
(2,3,57,'2025-10-05 05:09:29'),
(2,4,63,'2025-10-11 12:44:40'),
(3,1,23,'2025-08-20 10:11:27'),
(3,3,17,'2025-08-17 18:42:42'),
(5,3,40,'2025-09-14 11:57:27'),
(9,3,43,'2025-09-23 17:25:41'),
(10,3,48,'2025-09-20 04:45:30'),
(10,6,61,'2025-10-13 18:07:50'),
(12,2,54,'2025-09-28 07:09:36'),
(12,3,58,'2025-10-05 05:09:24');
/*!40000 ALTER TABLE `chat_reads` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `chats`
--

DROP TABLE IF EXISTS `chats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `chats` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `is_group` tinyint(1) NOT NULL DEFAULT 0,
  `name` varchar(100) DEFAULT NULL,
  `photo` varchar(255) DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `created_by` (`created_by`),
  CONSTRAINT `fk_chats_created_by_users` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chats`
--

LOCK TABLES `chats` WRITE;
/*!40000 ALTER TABLE `chats` DISABLE KEYS */;
INSERT INTO `chats` VALUES
(1,0,NULL,NULL,4,'2025-08-12 15:44:42','2025-08-12 15:44:42'),
(2,0,NULL,NULL,4,'2025-08-12 15:54:17','2025-08-12 15:54:17'),
(3,0,NULL,NULL,1,'2025-08-18 00:33:24','2025-08-18 00:33:24'),
(4,0,NULL,NULL,3,'2025-08-20 08:37:46','2025-08-20 08:37:46'),
(5,0,NULL,NULL,9,'2025-09-13 07:43:02','2025-09-13 07:43:02'),
(6,0,NULL,NULL,9,'2025-09-13 07:44:33','2025-09-13 07:44:33'),
(7,0,NULL,NULL,9,'2025-09-13 07:46:18','2025-09-13 07:46:18'),
(8,0,NULL,NULL,11,'2025-09-13 07:47:06','2025-09-13 07:47:06'),
(9,0,NULL,NULL,13,'2025-09-13 07:58:46','2025-09-13 07:58:46'),
(10,0,NULL,NULL,6,'2025-09-16 01:00:46','2025-09-16 01:00:46'),
(11,0,NULL,NULL,2,'2025-09-25 10:27:24','2025-09-25 10:27:24'),
(12,0,NULL,NULL,2,'2025-09-25 10:27:31','2025-09-25 10:27:31'),
(13,0,NULL,NULL,16,'2025-09-28 17:36:16','2025-09-28 17:36:16'),
(14,0,NULL,NULL,6,'2025-10-05 15:51:03','2025-10-05 15:51:03'),
(15,0,NULL,NULL,4,'2025-10-11 12:44:35','2025-10-11 12:44:35'),
(16,0,NULL,NULL,6,'2025-10-13 18:03:37','2025-10-13 18:03:37');
/*!40000 ALTER TABLE `chats` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `coaching_assignment_reviews`
--

DROP TABLE IF EXISTS `coaching_assignment_reviews`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `coaching_assignment_reviews` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `assignment_id` int(11) NOT NULL,
  `version_id` int(11) NOT NULL,
  `reviewer_id` int(11) NOT NULL,
  `decision` enum('approved','changes_requested','rejected') NOT NULL,
  `feedback` text DEFAULT NULL,
  `score` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `assignment_id` (`assignment_id`),
  KEY `version_id` (`version_id`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `coaching_assignment_reviews`
--

LOCK TABLES `coaching_assignment_reviews` WRITE;
/*!40000 ALTER TABLE `coaching_assignment_reviews` DISABLE KEYS */;
INSERT INTO `coaching_assignment_reviews` VALUES
(1,6,1,3,'rejected',NULL,NULL,'2025-09-07 02:40:37'),
(2,6,1,3,'rejected','Please make correction for next uses',30,'2025-09-07 03:08:48'),
(3,6,1,3,'rejected','review it',NULL,'2025-09-07 03:26:17'),
(4,6,1,3,'rejected','rejecteddd',NULL,'2025-09-07 03:32:12'),
(5,6,1,3,'rejected','hii',NULL,'2025-09-07 03:36:29'),
(6,6,2,3,'approved','Well done',90,'2025-09-07 03:38:09'),
(7,8,3,3,'rejected','please resubmit',NULL,'2025-09-07 16:24:17'),
(8,8,4,3,'rejected',NULL,NULL,'2025-09-07 16:27:25'),
(9,8,5,6,'approved','Well done',80,'2025-09-16 01:03:26'),
(10,8,5,6,'approved','Great insights on your product',60,'2025-09-16 01:04:24'),
(11,6,2,6,'approved','Cool',10,'2025-09-16 01:04:57'),
(12,8,5,3,'approved','Great Advice',5,'2025-09-25 07:26:31'),
(13,9,6,6,'approved',NULL,NULL,'2025-09-28 20:28:28'),
(14,12,7,6,'approved',NULL,NULL,'2025-09-29 22:57:41'),
(15,12,7,6,'approved','asfga',NULL,'2025-09-29 22:57:51'),
(16,12,7,6,'approved',NULL,NULL,'2025-09-29 22:58:12'),
(17,12,7,3,'approved',NULL,NULL,'2025-10-05 07:18:31'),
(18,13,8,6,'approved',NULL,NULL,'2025-10-13 17:43:48'),
(19,14,9,6,'approved',NULL,NULL,'2025-10-13 17:43:55');
/*!40000 ALTER TABLE `coaching_assignment_reviews` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `coaching_assignment_versions`
--

DROP TABLE IF EXISTS `coaching_assignment_versions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `coaching_assignment_versions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `assignment_id` int(11) NOT NULL,
  `seq` int(11) NOT NULL,
  `submitted_by` int(11) NOT NULL,
  `submitted_at` datetime NOT NULL DEFAULT current_timestamp(),
  `text` longtext DEFAULT NULL,
  `links_json` text DEFAULT NULL,
  `files_json` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_assignment_seq` (`assignment_id`,`seq`),
  KEY `idx_assignment` (`assignment_id`),
  KEY `fk_cav_user` (`submitted_by`),
  CONSTRAINT `fk_cav_assignment` FOREIGN KEY (`assignment_id`) REFERENCES `coaching_assignments` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_cav_user` FOREIGN KEY (`submitted_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `coaching_assignment_versions`
--

LOCK TABLES `coaching_assignment_versions` WRITE;
/*!40000 ALTER TABLE `coaching_assignment_versions` DISABLE KEYS */;
INSERT INTO `coaching_assignment_versions` VALUES
(1,6,1,2,'2025-09-07 00:14:27','<p>hello</p>','[]','[\"/uploads/assignments/1757182467154_Firefox_Cors_Uploads_____Team_Playbook__mobionizer_mdm_.pdf\"]'),
(2,6,2,2,'2025-09-07 03:37:20','<p>Please check again</p>','[]','[]'),
(3,8,1,2,'2025-09-07 15:49:39','<p>This my new update for your review</p>','[]','[\"/uploads/assignments/1757238579931_2025-09-03_160813.png\"]'),
(4,8,2,2,'2025-09-07 16:25:07','<p>Resubmited data</p>','[]','[\"/uploads/assignments/1757240707773_2025-09-01_164846.png\"]'),
(5,8,3,2,'2025-09-07 16:27:56','<p>resubmit -2</p>','[]','[\"/uploads/coaching/assignments/1757240876045_2025-09-04_110346.png\"]'),
(6,9,1,2,'2025-09-25 10:24:41','Hello Norman','[\"https://www.facebook.com/\"]','[\"/uploads/coaching/assignments/1758795872785_full-stack-development.png\"]'),
(7,12,1,17,'2025-09-28 20:27:26','<p><strong>My Coaching Assignment Response - Step #1</strong></p><p><strong>1. Type of Job I Do:</strong> I\'m a Senior Policy Analyst in the Department of Health, working on healthcare accessibility initiatives. My daily responsibilities include analyzing health data trends, drafting policy recommendations, coordinating with stakeholders across multiple agencies, and preparing briefing materials for senior leadership. I spend about 60% of my time on research and analysis, 30% in meetings and consultations, and 10% on administrative tasks.</p><p><strong>2. Passion Projects:</strong></p><ul><li><strong>Community Health Workshops</strong>: I volunteer weekends teaching digital literacy to seniors in my neighborhood, helping them navigate online healthcare portals and telehealth services</li><li><strong>Data Visualization Blog</strong>: I create infographics that translate complex health statistics into accessible visuals for the general public</li><li><strong>Mentorship Program</strong>: I mentor junior analysts in our department, focusing on effective communication and stakeholder engagement skills</li></ul><p><strong>3. What I\'m Curious About:</strong></p><ul><li><strong>AI for Policy Analysis</strong>: How machine learning could help identify patterns in large datasets to predict health outcomes and inform proactive policy decisions</li><li><strong>Cross-Cultural Communication</strong>: Better techniques for engaging diverse communities in policy development processes</li><li><strong>Process Automation</strong>: Which repetitive tasks in policy work could be streamlined to free up time for strategic thinking and stakeholder relationship building</li></ul><p>This background helps my coach understand I\'m analytically-minded, community-focused, and interested in leveraging technology to improve both efficiency and public service delivery.</p>','[]','[]'),
(8,13,1,17,'2025-10-13 17:04:18','<p>Here is what i think and it si right we are on track to gettign there.</p>','[]','[]'),
(9,14,1,17,'2025-10-13 17:04:54','','[]','[]');
/*!40000 ALTER TABLE `coaching_assignment_versions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `coaching_assignments`
--

DROP TABLE IF EXISTS `coaching_assignments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `coaching_assignments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `enrollment_id` int(11) NOT NULL,
  `step_id` int(11) DEFAULT NULL,
  `step_seq` int(11) NOT NULL,
  `title` varchar(200) NOT NULL,
  `instructions` text DEFAULT NULL,
  `due_at` datetime DEFAULT NULL,
  `status` enum('not_started','submitted','in_review','changes_requested','approved','rejected','overdue') DEFAULT 'not_started',
  PRIMARY KEY (`id`),
  KEY `idx_ca_enrollment_status_due` (`enrollment_id`,`status`,`due_at`),
  CONSTRAINT `coaching_assignments_ibfk_1` FOREIGN KEY (`enrollment_id`) REFERENCES `coaching_enrollments` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `coaching_assignments`
--

LOCK TABLES `coaching_assignments` WRITE;
/*!40000 ALTER TABLE `coaching_assignments` DISABLE KEYS */;
INSERT INTO `coaching_assignments` VALUES
(1,1,NULL,1,'Intake & Goals','Define goals & baseline','2025-08-20 00:00:00','not_started'),
(2,1,NULL,3,'Self-paced','','2025-09-03 00:00:00','not_started'),
(3,5,NULL,0,'',NULL,NULL,'not_started'),
(4,5,NULL,0,'',NULL,NULL,'not_started'),
(5,5,NULL,1,'',NULL,NULL,'not_started'),
(6,5,9,1,'Introduction',NULL,NULL,'approved'),
(7,4,19,1,'Assigment',NULL,NULL,'not_started'),
(8,6,23,1,'Introductions','<p>Please provide your introductions. Let me know your skill and plan for next 1 week.</p>',NULL,'approved'),
(9,6,41,3,'Practical Session #2 With Real Data','<p>Practical Session #2 With Real Data</p>',NULL,'approved'),
(10,6,39,1,'Introductions','<p>Please provide your introductions. Let me know your skill and plan for next 1 week.</p>',NULL,'not_started'),
(11,7,181,1,'Intro','<p>Increasing Social Media Followers for all social media platform</p>',NULL,'not_started'),
(12,12,206,1,'Assignment 1: Type of Job You Do, Any Passion Projects You Might Have, What Are You Curious About?','<p>Before we begin your coaching program, I need to learn more about you so I can tailor the training to your specific needs. Please prepare a short note that covers three key elements to the best of your ability:</p><ol><li><strong>The type of job you do</strong></li><li>Describe your current role in the public service. Include your main responsibilities and the kind of work you handle on a daily basis.</li><li><strong>Any passion projects you have</strong></li><li>Share personal or professional projects that matter to you. These could be volunteer activities, community work, research interests, or creative projects you enjoy outside your main job.</li><li><strong>What you are curious about</strong></li><li>Tell me what you want to learn or explore. This could be skills you want to develop, topics that interest you, or areas where you think AI could make a difference in your work or life.</li></ol><p><br></p><p>By completing this assignment, you give me the background I need to design a personalized coaching plan that fits your goals and helps you get the most value from the program.</p>',NULL,'approved'),
(13,18,275,1,'Homework 1 (Weeks 2–3): Startup Snapshot & Current Challenge','<ul><li><strong>Founder task:</strong> Share <strong>pitch deck draft, mission, vision, milestones to date, and biggest challenge now</strong>.</li><li><strong>Result:</strong> Norman gets a full picture to tailor guidance. Founder gets clarity on what they want to achieve.</li></ul>',NULL,'approved'),
(14,18,277,3,'Homework 2 (Weeks 5–6): Customer Validation & Product Testing','<ul><li><strong>Founder task:</strong> Conduct <strong>customer discovery or MVP testing</strong> (interviews, surveys, pilot runs).</li><li><strong>Result:</strong> Founders collect <strong>real customer insights</strong>, refine product features, and validate demand.</li></ul>',NULL,'approved');
/*!40000 ALTER TABLE `coaching_assignments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `coaching_bookings`
--

DROP TABLE IF EXISTS `coaching_bookings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `coaching_bookings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `enrollment_id` int(11) NOT NULL,
  `step_seq` int(11) NOT NULL,
  `meeting_id` int(11) NOT NULL,
  `status` enum('scheduled','completed','no_show','rescheduled') DEFAULT 'scheduled',
  PRIMARY KEY (`id`),
  KEY `idx_cb_enrollment_step` (`enrollment_id`,`step_seq`),
  CONSTRAINT `coaching_bookings_ibfk_1` FOREIGN KEY (`enrollment_id`) REFERENCES `coaching_enrollments` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `coaching_bookings`
--

LOCK TABLES `coaching_bookings` WRITE;
/*!40000 ALTER TABLE `coaching_bookings` DISABLE KEYS */;
INSERT INTO `coaching_bookings` VALUES
(1,1,2,0,'scheduled'),
(2,1,4,0,'scheduled');
/*!40000 ALTER TABLE `coaching_bookings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `coaching_enrollments`
--

DROP TABLE IF EXISTS `coaching_enrollments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `coaching_enrollments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `client_id` int(11) NOT NULL,
  `coach_id` int(11) NOT NULL,
  `template_id` int(11) NOT NULL,
  `start_date` date NOT NULL,
  `status` enum('active','paused','completed','cancelled') DEFAULT 'active',
  `next_step_seq` int(11) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `order_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_coach_enroll_order` (`order_id`),
  KEY `ix_enr_user_expert` (`client_id`,`coach_id`),
  KEY `ix_enr_status` (`status`),
  KEY `ix_enr_template` (`template_id`),
  CONSTRAINT `fk_coach_enroll_order` FOREIGN KEY (`order_id`) REFERENCES `coaching_orders` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `coaching_enrollments`
--

LOCK TABLES `coaching_enrollments` WRITE;
/*!40000 ALTER TABLE `coaching_enrollments` DISABLE KEYS */;
INSERT INTO `coaching_enrollments` VALUES
(1,5,3,1,'2025-08-22','active',1,'2025-08-22 15:46:43',NULL),
(2,0,0,3,'2025-09-01','active',1,'2025-09-01 07:35:08',6),
(3,0,0,3,'2025-09-01','active',1,'2025-09-01 16:01:42',11),
(4,2,3,3,'2025-09-02','active',1,'2025-09-01 18:21:09',13),
(5,2,3,2,'2025-09-02','active',1,'2025-09-01 18:50:49',9),
(6,2,3,5,'2025-09-07','active',1,'2025-09-07 08:45:16',15),
(7,13,6,7,'2025-09-13','active',1,'2025-09-13 08:01:43',16),
(8,16,6,6,'2025-09-28','active',1,'2025-09-28 15:29:43',26),
(9,16,6,6,'2025-09-28','active',1,'2025-09-28 17:12:35',27),
(10,16,6,6,'2025-09-28','active',1,'2025-09-28 17:37:56',28),
(11,16,6,6,'2025-09-28','active',1,'2025-09-28 17:44:36',29),
(12,17,6,9,'2025-09-28','active',1,'2025-09-28 20:22:03',31),
(13,2,3,8,'2025-10-04','active',1,'2025-10-04 18:11:23',21),
(14,4,6,9,'2025-10-05','active',1,'2025-10-05 07:35:08',25),
(15,6,6,9,'2025-10-05','active',1,'2025-10-05 15:39:19',24),
(16,18,6,6,'2025-10-12','active',1,'2025-10-12 18:14:46',34),
(17,18,6,6,'2025-10-12','active',1,'2025-10-12 18:27:23',35),
(18,17,6,6,'2025-10-12','active',1,'2025-10-12 18:31:04',36),
(19,18,6,6,'2025-10-16','active',1,'2025-10-16 22:58:13',40);
/*!40000 ALTER TABLE `coaching_enrollments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `coaching_orders`
--

DROP TABLE IF EXISTS `coaching_orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `coaching_orders` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `template_id` int(11) NOT NULL,
  `amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `currency` varchar(10) NOT NULL DEFAULT 'USD',
  `status` enum('pending','paid','failed','cancelled') NOT NULL DEFAULT 'pending',
  `payment_status` enum('pending','paid','failed','cancelled') NOT NULL DEFAULT 'pending',
  `payment_ref` varchar(128) DEFAULT NULL,
  `stripe_payment_intent_id` varchar(64) DEFAULT NULL,
  `provider_payment_intent_id` varchar(64) DEFAULT NULL,
  `paid_at` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `template_id` (`template_id`),
  KEY `status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=41 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `coaching_orders`
--

LOCK TABLES `coaching_orders` WRITE;
/*!40000 ALTER TABLE `coaching_orders` DISABLE KEYS */;
INSERT INTO `coaching_orders` VALUES
(1,3,1,499.00,'USD','pending','pending',NULL,NULL,NULL,NULL,'2025-08-22 17:43:23','2025-08-22 17:43:23'),
(2,3,1,499.00,'USD','pending','pending',NULL,NULL,NULL,NULL,'2025-08-22 17:43:23','2025-08-22 17:43:23'),
(3,3,3,20.00,'USD','pending','pending',NULL,NULL,NULL,NULL,'2025-08-23 14:10:01','2025-08-23 14:10:01'),
(4,3,3,20.00,'USD','pending','pending',NULL,NULL,NULL,NULL,'2025-08-23 14:10:01','2025-08-23 14:10:01'),
(5,3,2,20.00,'USD','pending','pending',NULL,NULL,NULL,NULL,'2025-08-23 14:29:03','2025-08-23 14:29:03'),
(6,2,3,20.00,'USD','paid','paid','pi_3S2SGe3RqEMUJuhk1QxxUL6w','pi_3S2SGe3RqEMUJuhk1QxxUL6w','pi_3S2SGe3RqEMUJuhk1QxxUL6w','2025-09-01 13:35:08','2025-08-24 08:55:52','2025-09-01 07:35:08'),
(7,2,3,20.00,'USD','paid','paid',NULL,NULL,'pi_3S2S5i3RqEMUJuhk1cwpLiph','2025-09-01 13:23:49','2025-08-24 08:55:52','2025-09-01 07:23:49'),
(8,2,2,20.00,'USD','pending','pending',NULL,NULL,NULL,NULL,'2025-08-24 09:49:05','2025-08-24 09:49:05'),
(9,2,2,20.00,'USD','paid','paid','pi_3S2coX3RqEMUJuhk1zfrTTgl','pi_3S2coX3RqEMUJuhk1zfrTTgl','pi_3S2coX3RqEMUJuhk1zfrTTgl','2025-09-02 00:50:48','2025-08-24 09:49:05','2025-09-01 18:50:48'),
(10,2,3,20.00,'USD','paid','paid','pi_3S2bSa3RqEMUJuhk04Y3L0PR','pi_3S2bSa3RqEMUJuhk04Y3L0PR','pi_3S2bSa3RqEMUJuhk04Y3L0PR','2025-09-01 23:24:04','2025-09-01 16:01:32','2025-09-01 17:24:04'),
(11,2,3,20.00,'USD','paid','paid','pi_3S2aAs3RqEMUJuhk147aoGln','pi_3S2aAs3RqEMUJuhk147aoGln','pi_3S2aAs3RqEMUJuhk147aoGln','2025-09-01 22:01:42','2025-09-01 16:01:32','2025-09-01 16:01:42'),
(12,2,3,20.00,'USD','pending','pending',NULL,NULL,NULL,NULL,'2025-09-01 18:00:22','2025-09-01 18:00:22'),
(13,2,3,20.00,'USD','paid','paid','pi_3S2c1p3RqEMUJuhk1MvsHIHT','pi_3S2c1p3RqEMUJuhk1MvsHIHT','pi_3S2c1p3RqEMUJuhk1MvsHIHT','2025-09-02 00:00:28','2025-09-01 18:00:22','2025-09-01 18:00:28'),
(14,2,5,20.00,'USD','pending','pending',NULL,NULL,NULL,NULL,'2025-09-07 06:23:12','2025-09-07 06:23:12'),
(15,2,5,20.00,'USD','paid','paid',NULL,NULL,'pi_3S4eDn3RqEMUJuhk1FVDR5mP','2025-09-07 14:45:16','2025-09-07 06:23:12','2025-09-07 08:45:16'),
(16,13,7,20.00,'USD','paid','paid',NULL,'pi_3S6oOp3RqEMUJuhk12LrB6G7','pi_3S6oOp3RqEMUJuhk12LrB6G7','2025-09-13 08:01:35','2025-09-13 07:59:32','2025-09-13 08:01:43'),
(17,13,7,20.00,'USD','pending','pending',NULL,NULL,NULL,NULL,'2025-09-13 10:55:57','2025-09-13 10:55:57'),
(18,6,6,600.00,'USD','pending','pending',NULL,NULL,NULL,NULL,'2025-09-16 01:02:06','2025-09-16 01:02:06'),
(19,3,7,20.00,'USD','pending','pending',NULL,NULL,NULL,NULL,'2025-09-25 06:43:05','2025-09-25 06:43:05'),
(20,3,8,900.00,'USD','pending','pending',NULL,NULL,NULL,NULL,'2025-09-25 07:25:24','2025-09-25 07:25:24'),
(21,2,8,900.00,'USD','paid','paid',NULL,'pi_3SEZvF3RqEMUJuhk1ybruVF9','pi_3SEZvF3RqEMUJuhk1ybruVF9','2025-10-04 18:11:09','2025-09-25 10:20:37','2025-10-04 18:11:23'),
(22,4,8,900.00,'USD','pending','pending',NULL,NULL,NULL,NULL,'2025-09-25 10:31:56','2025-09-25 10:31:56'),
(23,4,2,20.00,'USD','pending','pending',NULL,NULL,NULL,NULL,'2025-09-25 10:33:19','2025-09-25 10:33:19'),
(24,6,9,300.00,'USD','paid','paid',NULL,'pi_3SEu0S3RqEMUJuhk1bckn2cg','pi_3SEu0S3RqEMUJuhk1bckn2cg','2025-10-05 15:37:52','2025-09-26 01:24:21','2025-10-05 15:39:19'),
(25,4,9,300.00,'USD','paid','paid',NULL,'pi_3SEmTC3RqEMUJuhk01dJy2Mg','pi_3SEmTC3RqEMUJuhk01dJy2Mg','2025-10-05 07:35:02','2025-09-27 11:24:44','2025-10-05 07:35:08'),
(26,16,6,0.00,'USD','paid','paid',NULL,NULL,NULL,'2025-09-28 15:29:43','2025-09-28 15:29:29','2025-09-28 15:29:43'),
(27,16,6,0.00,'USD','paid','paid',NULL,NULL,NULL,'2025-09-28 17:12:35','2025-09-28 17:12:25','2025-09-28 17:12:35'),
(28,16,6,0.00,'USD','paid','paid',NULL,NULL,NULL,'2025-09-28 17:37:56','2025-09-28 17:37:40','2025-09-28 17:37:56'),
(29,16,6,0.00,'USD','paid','paid',NULL,NULL,NULL,'2025-09-28 17:44:36','2025-09-28 17:44:26','2025-09-28 17:44:36'),
(30,16,10,500.00,'USD','pending','pending',NULL,NULL,NULL,NULL,'2025-09-28 18:33:40','2025-09-28 18:33:40'),
(31,17,9,300.00,'USD','paid','paid',NULL,'pi_3SCR6X3RqEMUJuhk1KTgLnP5','pi_3SCR6X3RqEMUJuhk1KTgLnP5','2025-09-28 20:21:57','2025-09-28 20:20:57','2025-09-28 20:22:03'),
(32,6,10,500.00,'USD','pending','pending',NULL,NULL,NULL,NULL,'2025-10-05 15:34:50','2025-10-05 15:34:50'),
(33,3,10,500.00,'USD','pending','pending',NULL,NULL,NULL,NULL,'2025-10-09 15:19:45','2025-10-09 15:19:45'),
(34,18,6,600.00,'USD','paid','paid',NULL,'pi_3SHTn23RqEMUJuhk0WonHzzX','pi_3SHTn23RqEMUJuhk0WonHzzX','2025-10-12 18:14:40','2025-10-12 18:12:50','2025-10-12 18:14:46'),
(35,18,6,600.00,'USD','paid','paid',NULL,'pi_3SHTzF3RqEMUJuhk1Ke7MtJZ','pi_3SHTzF3RqEMUJuhk1Ke7MtJZ','2025-10-12 18:27:17','2025-10-12 18:24:35','2025-10-12 18:27:23'),
(36,17,6,600.00,'USD','paid','paid',NULL,'pi_3SHU2o3RqEMUJuhk1Wq6c7gw','pi_3SHU2o3RqEMUJuhk1Wq6c7gw','2025-10-12 18:30:58','2025-10-12 18:24:43','2025-10-12 18:31:04'),
(37,17,12,1000.00,'USD','pending','pending',NULL,NULL,NULL,NULL,'2025-10-12 18:29:38','2025-10-12 18:29:38'),
(38,3,4,15.00,'USD','pending','pending',NULL,NULL,NULL,NULL,'2025-10-14 04:31:11','2025-10-14 04:31:11'),
(39,3,4,15.00,'USD','pending','pending',NULL,NULL,NULL,NULL,'2025-10-14 04:31:11','2025-10-14 04:31:11'),
(40,18,6,600.00,'USD','paid','paid',NULL,'pi_3SJ07X3RqEMUJuhk0UuJwGwR','pi_3SJ07X3RqEMUJuhk0UuJwGwR','2025-10-16 22:58:07','2025-10-16 22:55:15','2025-10-16 22:58:13');
/*!40000 ALTER TABLE `coaching_orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `coaching_program_slots`
--

DROP TABLE IF EXISTS `coaching_program_slots`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `coaching_program_slots` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `template_id` int(11) NOT NULL,
  `expert_id` int(11) DEFAULT NULL,
  `start_time` datetime NOT NULL,
  `end_time` datetime NOT NULL,
  `capacity` int(11) NOT NULL DEFAULT 1,
  `seats_taken` int(11) NOT NULL DEFAULT 0,
  `status` enum('open','hidden','cancelled') NOT NULL DEFAULT 'open',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_template_time` (`template_id`,`start_time`),
  CONSTRAINT `fk_cps_template` FOREIGN KEY (`template_id`) REFERENCES `coaching_program_templates` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `coaching_program_slots`
--

LOCK TABLES `coaching_program_slots` WRITE;
/*!40000 ALTER TABLE `coaching_program_slots` DISABLE KEYS */;
/*!40000 ALTER TABLE `coaching_program_slots` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `coaching_program_steps`
--

DROP TABLE IF EXISTS `coaching_program_steps`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `coaching_program_steps` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `template_id` int(11) NOT NULL,
  `seq` int(11) NOT NULL,
  `step_type` enum('live','self_paced') NOT NULL,
  `title` varchar(200) NOT NULL,
  `description` text DEFAULT NULL,
  `due_offset_days` int(11) DEFAULT NULL,
  `required_submission` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `template_id` (`template_id`),
  CONSTRAINT `coaching_program_steps_ibfk_1` FOREIGN KEY (`template_id`) REFERENCES `coaching_program_templates` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `coaching_program_steps`
--

LOCK TABLES `coaching_program_steps` WRITE;
/*!40000 ALTER TABLE `coaching_program_steps` DISABLE KEYS */;
INSERT INTO `coaching_program_steps` VALUES
(1,1,1,'self_paced','Intake & Goals','Define goals & baseline',2,1),
(2,1,2,'live','Session 1: Kickoff','Review goals',NULL,NULL),
(3,1,3,'self_paced','Self-paced','',2,1),
(4,1,4,'live','Session 2','',NULL,NULL);
/*!40000 ALTER TABLE `coaching_program_steps` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `coaching_program_templates`
--

DROP TABLE IF EXISTS `coaching_program_templates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `coaching_program_templates` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `coach_id` int(11) NOT NULL,
  `title` varchar(255) DEFAULT NULL,
  `price` decimal(10,2) NOT NULL,
  `duration_months` tinyint(3) unsigned NOT NULL,
  `cadence_weeks` tinyint(4) NOT NULL DEFAULT 2,
  `total_live_sessions` tinyint(4) NOT NULL,
  `summary` varchar(255) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `slug` varchar(190) DEFAULT NULL,
  `images_json` longtext DEFAULT NULL CHECK (json_valid(`images_json`)),
  `description` mediumtext DEFAULT NULL,
  `currency` varchar(10) NOT NULL DEFAULT 'USD',
  `cover_image` varchar(512) DEFAULT NULL,
  `image` varchar(512) DEFAULT NULL,
  `created_by` bigint(20) unsigned DEFAULT NULL,
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `slug` (`slug`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `coaching_program_templates`
--

LOCK TABLES `coaching_program_templates` WRITE;
/*!40000 ALTER TABLE `coaching_program_templates` DISABLE KEYS */;
INSERT INTO `coaching_program_templates` VALUES
(1,2,'Career Acceleration',499.00,3,2,12,'Bi-weekly live sessions with self-paced work.',1,'2025-08-22 15:45:30',NULL,NULL,NULL,'USD',NULL,NULL,NULL,'2025-09-09 01:31:54',NULL),
(2,3,'This is long course',20.00,9,2,6,'This is long course',1,'2025-08-22 20:52:06','this-is-long-course','[]','<p>This is the sample data</p>','USD','/uploads/coaching/1755930164873_2025-08-21_210359.png','/uploads/coaching/1755930164873_2025-08-21_210359.png',NULL,'2025-09-09 01:31:54',NULL),
(3,3,'This is long course',20.00,0,2,6,'This is long course',1,'2025-08-22 21:02:05','this-is-long-course-1','[]','<p>This is the sample data for the coaching program.</p>','USD','/uploads/coaching/1755932077934_2025-08-19_160347.png','/uploads/coaching/1755932077934_2025-08-19_160347.png',NULL,'2025-08-23 20:53:24',NULL),
(4,3,'Test 2😁',15.00,3,2,6,'',1,'2025-08-22 21:04:10','test-2','[]','<p>Test 2😁</p>','USD','/uploads/coaching/1757849024369_1.png','/uploads/coaching/1757849024369_1.png',NULL,'2025-09-14 11:23:45',NULL),
(5,3,'Increasing Social Media Followers',20.00,12,2,4,'Increasing Social Media Followers for all social media platform',1,'2025-09-07 06:19:57','increasing-social-media-followers','[]','<h2><strong><u>Increasing Social Media Followers for all social media platform</u></strong></h2><p><br></p><p>Make sure your server is running the updated controller (restart if needed).</p><p>Confirm the request is hitting this route (watch the new console log line).</p><p>Ensure you’re logged in as the assignment’s coach (or admin). Non-coach experts will get 403 and no update.</p><p>Confirm you’re connected to the intended database (no shadow env).</p>','USD','/uploads/coaching/1757225997093_2025-08-04_181757.png','/uploads/coaching/1757225997093_2025-08-04_181757.png',3,'2025-09-09 01:31:54',NULL),
(6,6,'New Startup Venture Results-Driven Coaching Program',600.00,3,2,3,'This is not a lecture series, it’s a guided journey that takes you from idea to traction and funding readiness in three months.',1,'2025-09-07 18:02:11','new-startup-venture-results-driven-coaching-program','[]','<h2><strong>Program Overview</strong></h2><p>Building a startup is tough — but you don’t have to do it alone. The <strong>New Startup Venture Results-Driven Coaching Program</strong> is designed for early-stage founders who are serious about turning ideas into real, scalable businesses. Over <strong>12 weeks</strong>, you’ll combine <strong>3 live coaching sessions</strong> with <strong>3 structured homework check-ins</strong> to keep you accountable, focused, and moving forward.</p><p>By the end of the program, you’ll have a <strong>practical, implementable roadmap</strong> that includes:</p><ol><li>A validated product development plan</li><li>Real customer insights that shape your solution</li><li>A tailored funding strategy that fits your stage</li><li>A polished investor-ready pitch deck</li><li>A structured, actionable business plan</li><li>A clear 90-day roadmap to guide your next moves</li></ol><h3><br></h3><h3><strong>What Makes This Program Different</strong></h3><p>Most programs give you theory. This one gives you <strong>results</strong>.</p><ol><li><strong>Accountability + Action</strong>: Every live session builds on real homework, so you’re not just learning — you’re implementing.</li><li><strong>Hands-on Validation</strong>: You’ll test your product with real customers, not just in a classroom.</li><li><strong>Tailored Funding Guidance</strong>: Instead of generic funding tips, you’ll leave with a funding plan that fits your stage and industry.</li><li><strong>Pitch Deck That Works</strong>: By Week 12, you’ll have a story and deck designed to get investor and partner attention.</li></ol><p><br></p><p><strong>Why Work With Norman? </strong></p><p>Norman Musengimana is more than a coach — he’s a <strong>startup founder, advisor, and ecosystem builder</strong> who has worked with <strong>over 300 startup founders</strong> across industries. He has helped entrepreneurs move from <strong>napkin ideas to funded, scalable ventures</strong>.</p><p><br></p><p>Norman\'s edge as a new venture advisor?</p><ol><li><strong>Proven experience</strong>: with over 1,000 startups, small businesses and over 5 small business acquisitions and repositioning brought together to help you.</li><li><strong>Cross-industry experience</strong>: Norman has advised founders in tech, services, consumer products, and social impact.</li><li><strong>Global network &amp; insights</strong>: From Canada to international markets, he brings perspective on what it takes to grow and scale.</li><li><strong>Proven track record</strong>: Dozens of founders he has guided have gone on to secure funding, land customers, and build strong teams.</li><li><strong>Relatable and practical</strong>: Norman knows firsthand the challenges of starting up — his approach is <strong>realistic, supportive, and results-oriented</strong>.</li></ol><p><br></p><p>I am personally excited and looking forward to supporting, helping you achieve your next set of milestones.</p><p><br></p><p>See you soon,</p><p>Norman</p>','USD','/uploads/coaching/1760375803810_One_on_one_coachign_for_newcomers_in_new_ventures_and_entrepreneurs_-_Norman_Musengimana.jpg','/uploads/coaching/1760375803810_One_on_one_coachign_for_newcomers_in_new_ventures_and_entrepreneurs_-_Norman_Musengimana.jpg',6,'2025-10-13 17:16:43',NULL),
(7,6,'Increasing Social Media Followers',20.00,3,2,3,'Increasing Social Media Followers for all social media platform😇',0,'2025-09-09 19:02:33','increasing-social-media-followers-1','[]','<p>Increasing Social Media Followers for all social media platform </p>','USD','/uploads/coaching/1757444553000_2025-08-25_092509.png','/uploads/coaching/1757444553000_2025-08-25_092509.png',6,'2025-10-11 19:28:17','2025-10-11 19:28:17'),
(8,3,'NextGen Apps – Build the Future, One App at a Time',900.00,3,12,30,'Build the Future, One App at a Time',1,'2025-09-25 07:24:45','nextgen-apps-build-the-future-one-app-at-a-time','[]','<p>Develop innovative apps for Android and iOS. Learn coding, apply best practices, and deploy apps that delight users worldwide.Develop innovative apps for Android and iOS. Learn coding, apply best practices, and deploy apps that delight users worldwide.Develop innovative apps for Android and iOS. Learn coding, apply best practices, and deploy apps that delight users worldwide.Develop innovative apps for Android and iOS. Learn coding, apply best practices, and deploy apps that delight users worldwide.Develop innovative apps for Android and iOS. Learn coding, apply best practices, and deploy apps that delight users worldwide.Develop innovative apps for Android and iOS. Learn coding, apply best practices, and deploy apps that delight users worldwide.Develop innovative apps for Android and iOS. Learn coding, apply best practices, and deploy apps that delight users worldwide.Develop innovative apps for Android and iOS. Learn coding, apply best practices, and deploy apps that delight users worldwide.Develop innovative apps for Android and iOS. Learn coding, apply best practices, and deploy apps that delight users worldwide.Develop innovative apps for Android and iOS. Learn coding, apply best practices, and deploy apps that delight users worldwide.Develop innovative apps for Android and iOS. Learn coding, apply best practices, and deploy apps that delight users worldwide.Develop innovative apps for Android and iOS. Learn coding, apply best practices, and deploy apps that delight users worldwide.Develop innovative apps for Android and iOS. Learn coding, apply best practices, and deploy apps that delight users worldwide.Develop innovative apps for Android and iOS. Learn coding, apply best practices, and deploy apps that delight users worldwide.Develop innovative apps for Android and iOS. Learn coding, apply best practices, and deploy apps that delight users worldwide.Develop innovative apps for Android and iOS. Learn coding, apply best practices, and deploy apps that delight users worldwide.</p><p><br></p><p><br></p><p>Develop innovative apps for Android and iOS. Learn coding, apply best practices, and deploy apps that delight users worldwide.Develop innovative apps for Android and iOS. Learn coding, apply best practices, and deploy apps that delight users worldwide.Develop innovative apps for Android and iOS. Learn coding, apply best practices, and deploy apps that delight users worldwide.Develop innovative apps for Android and iOS. Learn coding, apply best practices, and deploy apps that delight users worldwide.Develop innovative apps for Android and iOS. Learn coding, apply best practices, and deploy apps that delight users worldwide.Develop innovative apps for Android and iOS. Learn coding, apply best practices, and deploy apps that delight users worldwide.</p><p><br></p><p><br></p><p>Develop innovative apps for Android and iOS. Learn coding, apply best practices, and deploy apps that delight users worldwide.Develop innovative apps for Android and iOS. Learn coding, apply best practices, and deploy apps that delight users worldwide.Develop innovative apps for Android and iOS. Learn coding, apply best practices, and deploy apps that delight users worldwide.Develop innovative apps for Android and iOS. Learn coding, apply best practices, and deploy apps that delight users worldwide.</p>','USD','/uploads/coaching/1758785085227_Next-Gen-Android-App-Development-for-Smarter-Businesses-scaled.jpg','/uploads/coaching/1758785085227_Next-Gen-Android-App-Development-for-Smarter-Businesses-scaled.jpg',3,'2025-09-25 07:24:45',NULL),
(9,6,'AI For Beginners: Public Service Professionals',300.00,3,2,4,'Personalized for Your own Career Growth. Stay Ahead. Stay Employable. Stay Relevant in a Fast Changing orld',1,'2025-09-25 16:37:12','ai-for-beginners-public-service-professionals','[]','<h3>The AI For Beginners: Public Service Professionals is a practical, and personalized coaching program for public service professionals who want to safely master AI for their own growth and career competitiveness, even if their department isn’t ready yet.</h3><p><br></p><h3><strong>Why This Matters:</strong></h3><ul><li><strong>Future-Proof Your Skills</strong> → Don’t wait for the government to decide. Build AI confidence now so your career stays relevant.</li><li><strong>Practical, Step-by-Step Guidance</strong> → From risk basics to choosing tools to using AI in real workflows — everything explained in plain language, one-on-one.</li><li><strong>Career Growth &amp; Security</strong> → Gain an edge in promotions, job mobility, and employability across federal, provincial, and municipal roles.</li></ul><p><br></p><p><br></p><h3><strong>Program Promise:</strong></h3><p>In just 5 steps, you’ll move from <em>AI beginner</em> to <em>confident user with a personal playbook</em> you can rely on every day:</p><ol><li><strong>Start AI</strong> → Understand risks, privacy, and where AI is safe to use, and more importantly, how to use it.</li><li><strong>Choose My Tools</strong> → Demystify AI prompting, and Find the right AI tools for your role or your passion projects.</li><li><strong>Get First Wins</strong> → See time savings in your daily briefs, notes, and emails.</li><li><strong>Own My Playbook</strong> → Build your personal, FOI-ready AI workflow.</li><li><strong>Build &amp; Lead My Team</strong> → Build unique AI teams that help you achieve various aspects of the work you enjoy doing through a collaborative approach with your team of AI experts and armies working collaboratively with you.</li></ol><p><br></p><h3><br></h3><p><strong>Your department might not be ready. But you can be.</strong></p><p>👉 <em>Book your one-on-one coaching spot today and start building your AI advantage.</em></p>','USD','/uploads/coaching/1760061012898_AI_For_Public_Servants_-_and_Public_Service_Professionals_Coaching_Sessions_and_Coaching_Programs-Prosfata-Norman_Musengimana.png','/uploads/coaching/1760061012898_AI_For_Public_Servants_-_and_Public_Service_Professionals_Coaching_Sessions_and_Coaching_Programs-Prosfata-Norman_Musengimana.png',6,'2025-10-10 01:50:13',NULL),
(10,6,'Lecturer or Teacher? Future-Proof Your Pedagogy: AI-Integrated Teaching Mastery',399.00,3,2,4,'Coaching for Next-Generation Lecturing & Teaching, Education for the Future',1,'2025-09-28 18:06:35','anthony','[]','<h2><strong>A Practical Coaching Program Designed and Customized for You: We Meet You Where You Are</strong></h2><p><br></p><p>The transformation of education is not a distant horizon; it is happening in classrooms right now. Every educator, whether you teach kindergarten or lead graduate seminars, faces a defining professional imperative: mastering AI integration is no longer optional; it is essential career currency. Suppose you find yourself anxious about students knowing more than you do about emerging tools, uncertain about ethical boundaries, or exhausted by the thought of yet another technology to learn. In that case, this program is your personalized pathway forward.</p><p><br></p><p>I know you care about your students, and I know that you want them to excel. <strong>I know this because the last person who had my back, who was invested in my success, was all the teachers that I met over the course of my educational background.</strong> So, allow me the opportunity to pay back to you in my own way, because I am who I am because of these wonderful teachers and lecturers I was lucky to meet.</p><p><br></p><p>This is not a generic professional development course. This is a bespoke, high-impact coaching experience designed to convert your AI uncertainty into immediate pedagogical advantage. We move decisively beyond abstract theory to deliver direct, actionable integration strategies that transform how you teach, assess, and engage. You will learn to leverage AI to reclaim dozens of hours by automating administrative burdens, dramatically amplify the efficiency and depth of your curriculum development, and create genuinely personalized learning environments that meet every student where they are, preparing them and yourself for an AI-saturated future.</p><p><br></p><h3><strong>Here Are the Three Main Takeaways:</strong></h3><ol><li>Master ai integration with confidence, step by step</li><li>Lead in an AI-driven educational landscape – don\'t be a follower</li><li>Become the architect of high-quality learning in the AI era</li></ol><p><br></p><h3><strong>What Makes This Program Different:</strong></h3><p>Every element is customized to you. Before each live coaching session, you submit your context, your experiments, your challenges, and your wins. I prepare specifically for your teaching environment, your student demographics, your institutional constraints, and your personal learning style. This is not one-size-fits-all professional development; this is your dedicated transformation partner over 90 days.</p><p><br></p><p>The program architecture balances strategic guidance with practical application. You will experience:</p><ol><li><strong>4 live coaching sessions</strong>: Real-time problem-solving and strategy refinement tailored to your classroom. Each session tackles your specific challenges, ensures measurable progress, and integrates the latest AI teaching trends.</li><li><strong>4 self-paced application labs</strong>: Apply AI tools directly in your teaching environment using <strong>custom frameworks and resources</strong>. Every lab produces <strong>tangible classroom improvements</strong> you can track and replicate.</li></ol><h2><br></h2><h2><strong>Program Outcomes: What You Will Achieve</strong></h2><h3><br></h3><h3><strong>Immediate Practical Skills</strong></h3><ul><li>Reclaim 5-10+ hours weekly through AI-assisted administrative automation</li><li>Design and deliver engaging AI-integrated learning experiences confidently</li><li>Implement ethical, transparent AI practices in your classroom</li><li>Develop personalized learning pathways at scale using AI insights</li></ul><h3><br></h3><h3><strong>Pedagogical Transformation</strong></h3><ul><li>Shift from information deliverer to learning experience facilitator</li><li>Master differentiation strategies that meet every student\'s needs</li><li>Build critical AI literacy in your students while leveraging AI\'s power</li><li>Design curriculum that prepares students for an AI-saturated future</li></ul><h3><br></h3><h3><strong>Professional Development</strong></h3><ul><li>Position yourself as an educational technology leader in your institution</li><li>Build confidence navigating rapid technological change</li><li>Develop adaptable skills that transfer across emerging tools</li><li>Create a sustainable AI integration practice that prevents burnout</li><li>Establish yourself as a resource for colleagues exploring AI</li></ul><h3><br></h3><h3><strong>Career Insurance</strong></h3><ul><li>Future-proof your teaching practice with in-demand skills</li><li>Demonstrate measurable innovation to administrators and stakeholders</li><li>Build a portfolio of AI-integrated learning experiences</li><li>Gain competitive advantage in education\'s evolving landscape</li><li>Ensure continued relevance and professional fulfillment</li></ul><h3><br></h3><h3><strong>Tangible Deliverables</strong></h3><ul><li>Your personalized AI Integration Playbook</li><li>Library of tested prompts and workflows for your subject area</li><li>Collection of AI-integrated lesson plans and assessments</li><li>Framework for evaluating new AI tools for educational appropriateness</li><li>We plan to build a community and network of fellow educators experimenting with AI integration</li></ul><h2><br></h2><h2><strong>Your Investment:</strong></h2><p><strong>Duration:</strong> 3 months (12 weeks)</p><p><strong>Value of the Program:</strong> 2,500 USD.</p><p><strong>Time Commitment:</strong></p><ul><li>4 live coaching sessions (60 minutes each)</li><li>4 self-paced experiences (1-5 hours each)</li><li>Weekly experimentation and implementation</li></ul><p><br></p><p><strong>What\'s Included:</strong></p><ul><li>4 personalized 1 on 1 live coaching sessions</li><li>Custom resources and tool recommendations for your context</li><li>Guided implementation frameworks and templates</li><li>Direct feedback on all your experiments and submissions</li><li>Access to curated AI tools and prompt secrets, and building your own prompt engineering system</li></ul><p><br></p><p><br></p><p>Whether your school fully supports AI or is still cautious, this program prepares you to thrive in either environment. You will learn how to integrate AI in ways that fit your institution’s policies while building your own professional growth path. Instead of losing hours on repetitive tasks, you’ll free up time to focus on powerful teaching, stronger student relationships, and becoming a trusted leader in your educational community.</p>','USD','/uploads/coaching/1760060799484_AI_For_Educators_Professors_Teachers_Coaching_Program.png','/uploads/coaching/1760060799484_AI_For_Educators_Professors_Teachers_Coaching_Program.png',6,'2025-10-10 01:50:56',NULL),
(11,6,'Erfa and Norman',0.00,3,1,9,'SC',0,'2025-10-10 12:15:01','erfa-and-norman','[]','<p>DES</p>','USD','/uploads/coaching/1760098501307_nDws3AhfbJPM3hs2EkB3nF-650-80.jpg.webp','/uploads/coaching/1760098501307_nDws3AhfbJPM3hs2EkB3nF-650-80.jpg.webp',6,'2025-10-12 18:14:14','2025-10-12 18:14:14'),
(12,6,'Rod and Norman Coaching',1000.00,6,2,6,'Eraly stage ',1,'2025-10-11 18:20:06','rod-and-norman-coaching','[]','','USD','/uploads/coaching/1760206806085_One_on_one_coachign_for_newcomers_in_new_countries_-_Norman_Musengimana.jpg','/uploads/coaching/1760206806085_One_on_one_coachign_for_newcomers_in_new_countries_-_Norman_Musengimana.jpg',6,'2025-10-11 19:28:10','2025-10-11 19:28:10');
/*!40000 ALTER TABLE `coaching_program_templates` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `coaching_reminder_logs`
--

DROP TABLE IF EXISTS `coaching_reminder_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `coaching_reminder_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `reminder_type` varchar(40) NOT NULL,
  `ref_id` varchar(100) NOT NULL,
  `recipient_email` varchar(190) NOT NULL,
  `sent_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_crl_type_ref` (`reminder_type`,`ref_id`),
  KEY `idx_crl_recipient` (`recipient_email`,`sent_at`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `coaching_reminder_logs`
--

LOCK TABLES `coaching_reminder_logs` WRITE;
/*!40000 ALTER TABLE `coaching_reminder_logs` DISABLE KEYS */;
INSERT INTO `coaching_reminder_logs` VALUES
(1,'DIGEST_48H','COACH','imranhossen1119999@gmail.com','2025-09-13 07:15:05'),
(2,'DIGEST_48H','COACH','norman@prosfata.com','2025-09-29 07:15:06');
/*!40000 ALTER TABLE `coaching_reminder_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `coaching_reviews`
--

DROP TABLE IF EXISTS `coaching_reviews`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `coaching_reviews` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `expert_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `enrollment_id` int(11) NOT NULL,
  `rating` tinyint(3) unsigned NOT NULL,
  `title` varchar(160) DEFAULT NULL,
  `comment` text DEFAULT NULL,
  `status` enum('pending','approved','rejected') NOT NULL DEFAULT 'pending',
  `is_public` tinyint(1) NOT NULL DEFAULT 1,
  `reply` text DEFAULT NULL,
  `replied_by` int(11) DEFAULT NULL,
  `replied_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_expert_enrollment` (`user_id`,`expert_id`,`enrollment_id`),
  KEY `ix_reviews_expert` (`expert_id`,`status`,`created_at`),
  KEY `ix_reviews_user` (`user_id`,`created_at`),
  KEY `fk_reviews_reply_by` (`replied_by`),
  KEY `ix_reviews_enr` (`enrollment_id`),
  CONSTRAINT `fk_reviews_enrollment` FOREIGN KEY (`enrollment_id`) REFERENCES `coaching_enrollments` (`id`),
  CONSTRAINT `fk_reviews_expert` FOREIGN KEY (`expert_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_reviews_reply_by` FOREIGN KEY (`replied_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_reviews_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `coaching_reviews`
--

LOCK TABLES `coaching_reviews` WRITE;
/*!40000 ALTER TABLE `coaching_reviews` DISABLE KEYS */;
INSERT INTO `coaching_reviews` VALUES
(1,3,2,6,5,NULL,'Excelent Coaching Program','approved',1,NULL,NULL,NULL,'2025-09-12 21:27:29','2025-09-12 21:42:08',NULL),
(2,3,2,5,5,NULL,'Hi','approved',1,NULL,NULL,NULL,'2025-09-12 21:28:30','2025-09-12 21:42:13',NULL);
/*!40000 ALTER TABLE `coaching_reviews` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `bi_coaching_reviews` BEFORE INSERT ON `coaching_reviews` FOR EACH ROW BEGIN
  IF NEW.rating < 1 OR NEW.rating > 5 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'rating must be between 1 and 5';
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `bu_coaching_reviews` BEFORE UPDATE ON `coaching_reviews` FOR EACH ROW BEGIN
  IF NEW.rating < 1 OR NEW.rating > 5 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'rating must be between 1 and 5';
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `coaching_sessions`
--

DROP TABLE IF EXISTS `coaching_sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `coaching_sessions` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `enrollment_id` bigint(20) unsigned NOT NULL,
  `seq` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `kind` enum('assignment','session') NOT NULL DEFAULT 'session',
  `duration_minutes` int(11) DEFAULT NULL,
  `meeting_required` tinyint(1) NOT NULL DEFAULT 1,
  `scheduled_start` datetime DEFAULT NULL,
  `scheduled_end` datetime DEFAULT NULL,
  `meeting_id` varchar(64) DEFAULT NULL,
  `status` enum('unscheduled','scheduled','completed','cancelled','missed') NOT NULL DEFAULT 'unscheduled',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_enrollment_seq` (`enrollment_id`,`seq`),
  KEY `idx_enrollment` (`enrollment_id`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `coaching_sessions`
--

LOCK TABLES `coaching_sessions` WRITE;
/*!40000 ALTER TABLE `coaching_sessions` DISABLE KEYS */;
INSERT INTO `coaching_sessions` VALUES
(2,4,2,'Live Session','session',NULL,1,'2025-09-03 11:00:00','2025-09-03 12:00:00','11','scheduled','2025-09-02 20:59:54','2025-09-03 03:29:23'),
(3,5,2,'Live Session','session',NULL,1,'2025-09-08 09:00:00','2025-09-08 10:00:00','12','scheduled','2025-09-06 23:46:18','2025-09-06 23:46:18'),
(4,6,2,'We will Talk Next Step For You','session',NULL,1,'2025-09-26 12:00:00','2025-09-26 13:00:00','13','scheduled','2025-09-07 15:13:15','2025-09-25 10:23:09'),
(7,6,4,'We will real life business plan','session',NULL,1,'2025-09-26 11:00:00','2025-09-26 12:00:00','16','scheduled','2025-09-07 15:36:13','2025-09-25 10:22:38'),
(8,12,2,'Live Session 1: Start AI','session',NULL,1,'2025-09-28 22:00:00','2025-09-28 23:00:00','26','scheduled','2025-09-28 20:24:25','2025-09-28 20:24:25'),
(9,17,2,'Live Session 1 (Week 4): Diagnosis & Priorities','session',NULL,1,'2025-10-12 19:00:00','2025-10-12 20:00:00','28','scheduled','2025-10-12 18:33:01','2025-10-12 18:33:01'),
(10,18,6,'Live Session 3 (Week 11–12): Investor & Roadmap Readiness','session',NULL,1,'2025-10-25 15:00:00','2025-10-25 16:00:00','29','scheduled','2025-10-12 18:33:33','2025-10-12 18:34:38'),
(11,18,4,'Live Session 2 (Week 7): Go-to-Market & Funding Prep','session',NULL,1,'2025-10-26 10:00:00','2025-10-26 11:00:00','30','scheduled','2025-10-12 18:33:42','2025-10-12 18:34:34'),
(12,18,2,'Live Session 1 (Week 4): Diagnosis & Priorities','session',NULL,1,'2025-10-19 16:00:00','2025-10-19 17:00:00','31','scheduled','2025-10-12 18:33:49','2025-10-13 14:00:41'),
(13,17,4,'Live Session 2 (Week 7): Go-to-Market & Funding Prep','session',NULL,1,'2025-10-19 10:00:00','2025-10-19 11:00:00','32','scheduled','2025-10-12 18:34:06','2025-10-12 18:34:06'),
(14,17,6,'Live Session 3 (Week 11–12): Investor & Roadmap Readiness','session',NULL,1,'2025-10-26 14:00:00','2025-10-26 15:00:00','33','scheduled','2025-10-12 18:34:10','2025-10-12 18:34:10'),
(15,19,2,'Live Session 1 (Week 4): Diagnosis & Priorities','session',NULL,1,'2025-10-17 01:00:00','2025-10-17 02:00:00','34','scheduled','2025-10-16 22:58:34','2025-10-16 22:58:34'),
(16,19,4,'Live Session 2 (Week 7): Go-to-Market & Funding Prep','session',NULL,1,'2025-10-19 15:00:00','2025-10-19 16:00:00','35','scheduled','2025-10-16 22:58:40','2025-10-16 22:58:40'),
(17,19,6,'Live Session 3 (Week 11–12): Investor & Roadmap Readiness','session',NULL,1,'2025-10-19 14:00:00','2025-10-19 15:00:00','36','scheduled','2025-10-16 22:58:43','2025-10-16 22:58:43');
/*!40000 ALTER TABLE `coaching_sessions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `coaching_slot_holds`
--

DROP TABLE IF EXISTS `coaching_slot_holds`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `coaching_slot_holds` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `template_id` bigint(20) unsigned NOT NULL,
  `expert_id` bigint(20) unsigned NOT NULL,
  `user_id` bigint(20) unsigned NOT NULL,
  `start_time` datetime NOT NULL,
  `end_time` datetime NOT NULL,
  `expires_at` datetime NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_hold` (`expert_id`,`start_time`,`end_time`),
  KEY `idx_hold_lookup` (`expert_id`,`start_time`,`end_time`,`expires_at`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `coaching_slot_holds`
--

LOCK TABLES `coaching_slot_holds` WRITE;
/*!40000 ALTER TABLE `coaching_slot_holds` DISABLE KEYS */;
/*!40000 ALTER TABLE `coaching_slot_holds` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `coaching_submissions`
--

DROP TABLE IF EXISTS `coaching_submissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `coaching_submissions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `assignment_id` bigint(20) unsigned NOT NULL,
  `client_id` int(11) NOT NULL,
  `submitted_at` datetime NOT NULL,
  `files_json` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`files_json`)),
  `notes` text DEFAULT NULL,
  `status` enum('submitted','needs_changes','approved') DEFAULT 'submitted',
  `reviewed_by` int(11) DEFAULT NULL,
  `reviewed_at` datetime DEFAULT NULL,
  `feedback` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `assignment_id` (`assignment_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `coaching_submissions`
--

LOCK TABLES `coaching_submissions` WRITE;
/*!40000 ALTER TABLE `coaching_submissions` DISABLE KEYS */;
INSERT INTO `coaching_submissions` VALUES
(1,1,5,'2025-08-22 21:49:04','[]','hello','approved',3,'2025-08-22 21:49:44','Looks good.');
/*!40000 ALTER TABLE `coaching_submissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `coaching_template_categories`
--

DROP TABLE IF EXISTS `coaching_template_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `coaching_template_categories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `template_id` int(11) NOT NULL,
  `category_id` int(11) NOT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_template_cat` (`template_id`,`category_id`),
  KEY `idx_template` (`template_id`),
  KEY `idx_category` (`category_id`),
  CONSTRAINT `fk_ctc_category` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_ctc_template` FOREIGN KEY (`template_id`) REFERENCES `coaching_program_templates` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=61 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `coaching_template_categories`
--

LOCK TABLES `coaching_template_categories` WRITE;
/*!40000 ALTER TABLE `coaching_template_categories` DISABLE KEYS */;
INSERT INTO `coaching_template_categories` VALUES
(11,2,5,'2025-08-23 06:49:40'),
(12,2,11,'2025-08-23 06:49:40'),
(21,3,5,'2025-08-23 14:50:58'),
(22,3,11,'2025-08-23 14:50:58'),
(25,5,5,'2025-09-08 17:33:27'),
(26,5,11,'2025-09-08 17:33:27'),
(29,4,5,'2025-09-14 11:23:45'),
(30,4,11,'2025-09-14 11:23:45'),
(31,7,5,'2025-09-14 14:46:13'),
(32,7,11,'2025-09-14 14:46:13'),
(33,8,3,'2025-09-25 07:24:45'),
(34,8,2,'2025-09-25 07:24:45'),
(35,8,8,'2025-09-25 07:24:45'),
(36,8,7,'2025-09-25 07:24:45'),
(37,8,4,'2025-09-25 07:24:45'),
(38,8,14,'2025-09-25 07:24:45'),
(39,8,5,'2025-09-25 07:24:45'),
(51,9,14,'2025-10-10 01:50:13'),
(52,10,5,'2025-10-10 01:50:56'),
(53,10,14,'2025-10-10 01:50:56'),
(54,11,11,'2025-10-10 12:15:01'),
(55,12,11,'2025-10-11 18:20:06'),
(60,6,11,'2025-10-13 17:16:43');
/*!40000 ALTER TABLE `coaching_template_categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `coaching_template_images`
--

DROP TABLE IF EXISTS `coaching_template_images`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `coaching_template_images` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `template_id` int(11) NOT NULL,
  `image_url` varchar(1024) NOT NULL,
  `sort_order` int(11) DEFAULT 1,
  `is_cover` tinyint(1) DEFAULT 0,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `template_id` (`template_id`),
  CONSTRAINT `coaching_template_images_ibfk_1` FOREIGN KEY (`template_id`) REFERENCES `coaching_program_templates` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `coaching_template_images`
--

LOCK TABLES `coaching_template_images` WRITE;
/*!40000 ALTER TABLE `coaching_template_images` DISABLE KEYS */;
/*!40000 ALTER TABLE `coaching_template_images` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `coaching_template_steps`
--

DROP TABLE IF EXISTS `coaching_template_steps`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `coaching_template_steps` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `template_id` int(11) NOT NULL,
  `seq` int(11) NOT NULL DEFAULT 0,
  `title` varchar(255) NOT NULL,
  `description` mediumtext DEFAULT NULL,
  `kind` enum('assignment','session') NOT NULL DEFAULT 'assignment',
  `duration_weeks` int(11) DEFAULT NULL,
  `meeting_required` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_template_seq` (`template_id`,`seq`),
  CONSTRAINT `fk_cts_template` FOREIGN KEY (`template_id`) REFERENCES `coaching_program_templates` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=299 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `coaching_template_steps`
--

LOCK TABLES `coaching_template_steps` WRITE;
/*!40000 ALTER TABLE `coaching_template_steps` DISABLE KEYS */;
INSERT INTO `coaching_template_steps` VALUES
(9,2,1,'Introduction',NULL,'assignment',1,0,'2025-08-23 12:49:40','2025-08-23 12:49:40'),
(10,2,2,'Live Session',NULL,'session',1,1,'2025-08-23 12:49:40','2025-08-23 12:49:40'),
(19,3,1,'Assigment',NULL,'assignment',1,0,'2025-08-23 20:50:58','2025-08-23 20:50:58'),
(20,3,2,'Live Session',NULL,'session',1,1,'2025-08-23 20:50:58','2025-08-23 20:50:58'),
(39,5,1,'Introductions','<p>Please provide your introductions. Let me know your skill and plan for next 1 week.</p>','assignment',2,0,'2025-09-08 23:33:27','2025-09-08 23:33:27'),
(40,5,2,'We will Talk Next Step For You','<p>We will make a live sessions</p>','session',2,1,'2025-09-08 23:33:27','2025-09-08 23:33:27'),
(41,5,3,'Practical Session #2 With Real Data','<p>Practical Session #2 With Real Data</p>','assignment',2,0,'2025-09-08 23:33:27','2025-09-08 23:33:27'),
(42,5,4,'We will real life business plan','<p>We will real life business plan</p>','session',2,0,'2025-09-08 23:33:27','2025-09-08 23:33:27'),
(179,4,1,'1','<p>Test 2😁</p>','assignment',1,0,'2025-09-14 11:23:46','2025-09-14 11:23:46'),
(180,4,2,'2','<p>Test 2😁</p>','session',1,0,'2025-09-14 11:23:46','2025-09-14 11:23:46'),
(181,7,1,'Intro','<p>Increasing Social Media Followers for all social media platform</p>','assignment',2,0,'2025-09-14 14:46:13','2025-09-14 14:46:13'),
(182,7,2,'Live Session','<p>Increasing Social Media Followers for all social media platform</p>','session',NULL,0,'2025-09-14 14:46:13','2025-09-14 14:46:13'),
(183,7,3,'Intro 2','<p>Increasing Social Media Followers for all social media platform</p>','assignment',NULL,0,'2025-09-14 14:46:13','2025-09-14 14:46:13'),
(184,7,4,'Live Session 2','<p>Increasing Social Media Followers for all social media platform</p>','session',NULL,0,'2025-09-14 14:46:13','2025-09-14 14:46:13'),
(239,9,1,'Assignment 1: Type of Job You Do, Any Passion Projects You Might Have, What Are You Curious About?','<p>Before we begin your coaching program, I need to learn more about you so I can tailor the training to your specific needs. Please prepare a short note that covers three key elements to the best of your ability:</p><ol><li><strong>The type of job you do</strong></li><li>Describe your current role in the public service. Include your main responsibilities and the kind of work you handle on a daily basis.</li><li><strong>Any passion projects you have</strong></li><li>Share personal or professional projects that matter to you. These could be volunteer activities, community work, research interests, or creative projects you enjoy outside your main job.</li><li><strong>What you are curious about</strong></li><li>Tell me what you want to learn or explore. This could be skills you want to develop, topics that interest you, or areas where you think AI could make a difference in your work or life.</li></ol><p><br></p><p>By completing this assignment, you give me the background I need to design a personalized coaching plan that fits your goals and helps you get the most value from the program.</p>','assignment',1,0,'2025-10-10 01:50:13','2025-10-10 01:50:13'),
(240,9,2,'Live Session 1: Start AI','<p>In this session, we will focus on helping you begin your journey with AI in a way that is safe, practical, and directly connected to your work or other areas f interests. Together, we will:</p><ol><li><strong>Understand risks and privacy</strong></li><li>Learn what to watch out for when using AI, including privacy rules, accuracy issues, and areas where caution is needed.</li><li><strong>Identify where AI is safe to use</strong></li><li>Explore examples of tasks where AI can save time and add value without creating problems for your role.</li><li><strong>Learn how to use it in practice and AI prompting demystification and application.</strong></li><li>Start the journey of how to apply AI tools step by step in your daily work, based on the needs you shared in your first assignment.</li></ol><p><br></p><p>By the end of this session, you will feel more confident about where to start with AI and how to apply it responsibly in your professional and personal projects.</p>','session',2,1,'2025-10-10 01:50:13','2025-10-10 01:50:13'),
(241,9,3,'Assignment 2: Share Your First Wins with AI','<p>After our first live session, you now have the tools and confidence to begin trying AI in your daily work. This assignment is about applying what you learned and sharing your first results.</p><p><br></p><p>Please prepare a short note that includes:</p><ol><li><strong>What you tried, the challenges and opportunities you have identified while playing with AI tools of your choice.</strong></li><li>Describe one or two specific tasks where you used AI. For example, drafting a brief, preparing meeting notes, or writing a customer/friend, relative an email, and how that felt.</li><li><strong>What changed for you</strong></li><li>Explain how AI helped. Did it save you time, make the task easier, or improve the quality of your work? What clicked for you, and what didn\'t click for you?</li><li><strong>What you learned</strong></li><li>Share any lessons or surprises. This could include challenges you faced, ways you adapted, or ideas for future use.</li></ol><p><br></p><p>This step is about celebrating your progress, learning from one another, and building confidence to use AI more often in your daily work. as we prepare for our second live session.</p>','assignment',4,0,'2025-10-10 01:50:13','2025-10-10 01:50:13'),
(242,9,4,'Live Session 2: Maximizing AI Tools and Building Your Own AI Playbook','<p>Now that you have experienced your first wins with AI, it is time to take the next step. This session will help you move from experimenting with small tasks to building your own personalized way of working with AI.</p><p><br></p><p>Together, we will:</p><ol><li><strong>Answer your questions</strong></li><li>Explore the new ideas and “what ifs” you discovered after trying AI on your own.</li><li><strong>Discover advanced possibilities</strong></li><li>Learn how to build custom GPTs, set up personal projects, and design workflows that go beyond simple prompts.</li><li><strong>Work with images and documents</strong></li><li>See how to edit images, summarize long reports, and prepare outputs that fit public service needs.</li><li><strong>Build your personal playbook</strong></li><li>Create your own FOI-ready AI workflow so you can use AI confidently and responsibly in your daily work.</li></ol><p><br></p><p>By the end of this session, you will be in the driver’s seat. You will not only know what AI can do for you but also how to set up and guide the tools so they work the way you need them to.</p>','session',5,1,'2025-10-10 01:50:13','2025-10-10 01:50:13'),
(243,9,5,'Assignment 3: Build and Lead My GPTs Team of AI Experts','<p>Now that you can use AI confidently on your own, it is time to explore how AI can act as a team of advisors working alongside you. This assignment will guide you to design and test a small group of AI “experts” that help you with different parts of the work you enjoy.</p><p><br></p><p><strong>Objective:</strong></p><p>Learn how to set up a collaborative group of AI tools that can each take on a specific role, so you achieve more without doing everything alone.</p><h4><br></h4><h4><strong>Instructions</strong></h4><ol><li><strong>Choose 2–3 roles you want help with</strong></li><li><strong>Create simple job descriptions</strong></li><li><strong>Develop instructions</strong></li><li><strong>Test your AI advisors one by one</strong></li><li><strong>Bring your team together</strong></li><li><strong>Test your new team of AI experts working collaboratively to help you execute projects</strong></li></ol><h4><br></h4><h4><strong>Output to Bring to the Next Session</strong></h4><ul><li>A short list of your AI advisors, with their job descriptions</li><li>At least one example project where you used two or more advisors together</li><li>Notes on what worked well and what you would change next time</li></ul><p><br></p><p>This assignment helps you see how you can build an “AI army” around you to support your personal and professional projects. You will arrive at the next session ready to share your experience and learn new ways to expand your team.</p>','assignment',7,0,'2025-10-10 01:50:13','2025-10-10 01:50:13'),
(244,9,6,'Live Session 3: Build and Lead My GPTs Team of AI Experts','<p><strong>Purpose</strong></p><p>Answer all your questions, refine your personal team of AI advisors, and lock in a simple playbook you can use every day.</p><p><strong>What to bring</strong></p><ul><li>Your list of AI advisor roles and job descriptions from Assignment 3</li><li>One real project you want help with this month</li><li>Your notes on what worked and what did not</li></ul><p><strong>Agenda</strong></p><ol><li><strong>Quick goals check</strong></li><li>Confirm what you want your AI team to help you achieve in the next 30 days.</li><li><strong>Open questions</strong></li><li>Ask anything about tools, prompts, privacy, records, and good practice.</li><li><strong>One on one tuning</strong></li></ol><ul><li>Clarify each advisor role and success criteria</li><li>Improve instructions and add guardrails for tone, data, and sources</li><li>Set handoff steps so advisors can work together on one project</li></ul><ol><li><strong>Live build and test</strong></li></ol><ul><li>Run a short task with two or more advisors on your real project</li><li>Review the output and make fast edits to prompts and steps</li></ul><ol><li><strong>Quality and compliance check</strong></li></ol><ul><li>Add a simple log for prompts and outputs</li><li>Note what is safe to use and what needs review</li></ul><ol><li><strong>Save your playbook</strong></li></ol><ul><li>Finalize your advisor roster</li><li>Save your core prompts, checklists, and logging template</li></ul><ol><li><strong>Thirty day action plan</strong></li></ol><ul><li>Pick weekly routines</li><li>Set two success measures such as time saved and quality of output</li></ul><p><strong>You will leave with</strong></p><ul><li>A refined list of your AI advisors with clear job descriptions</li><li>A tested workflow for your chosen project</li><li>A short playbook that is ready for use and ready for records requests</li><li>A simple log template for privacy and audit</li><li>A thirty day plan with two success measures</li></ul><p><strong>Success measures to track</strong></p><ul><li>Minutes saved per task</li><li>Number of drafts reduced before final</li><li>On time delivery of briefs, notes, or posts</li><li>Clear record of sources and approvals</li></ul><p><strong>Preparation note</strong></p><p>If your department is not yet ready to adopt AI, you can still build personal skill and confidence. We will keep your workflow focused on safe personal use, simple logging, and clear boundaries so you protect your professionalism and stay competitive in the labor market.</p>','session',8,1,'2025-10-10 01:50:13','2025-10-10 01:50:13'),
(245,9,7,'Final Live Session: Final Live Session: Reflect and Grow Together','<p><strong>Purpose</strong></p><p>This final session is about coming together to reflect on your journey, share experiences, and build confidence to keep using AI as part of your personal and professional growth.</p><p><br></p><p><strong>What we will do together</strong></p><ol><li><strong>Celebrate progress</strong></li><li>Each participant shares highlights of their journey: first wins, successful workflows, and new skills gained.</li><li><strong>Learn from one another</strong></li><li>Open discussion on what worked well, what did not, and which tools or methods felt confusing, overwhelming, or surprising.</li><li><strong>Explore new discoveries</strong></li><li>Share any new tools, prompts, or approaches you found on your own since the last session, and see how others are experimenting too.</li><li><strong>Acknowledge challenges</strong></li><li>Talk openly about the parts that felt intimidating or “freaked you out,” and work together to identify safe and simple ways forward.</li><li><strong>Plan for the future</strong></li><li>Summarize your key takeaways, create a short personal plan for the next 90 days, and discuss how I can continue supporting you with coaching, resources, or advanced sessions.</li></ol><p><br></p><p><strong>You will leave with</strong></p><ul><li>A clear reflection on your growth from the first session to now</li><li>New ideas and strategies from your peers’ experiences</li><li>A personal 90-day plan to continue practicing and applying AI</li><li>A clear picture of how to keep receiving support and stay on track</li></ul>','session',11,1,'2025-10-10 01:50:13','2025-10-10 01:50:13'),
(246,10,1,'Foundation & Context Mapping (Self-Paced Assignment - Week 1)','<p><strong>Duration:</strong> 1 week</p><p><strong>Type:</strong> Assignment</p><p><strong>Meeting Required:</strong> No</p><p><br></p><p><strong>What You\'ll Submit:</strong></p><ul><li>Your comprehensive teaching profile (subject area, grade level, years of experience, institutional context)</li><li>Detailed learner profile (student demographics, learning needs, class sizes, delivery format)</li><li>Current AI experience level (tools you\'ve tried, comfort level, previous training)</li><li>Teaching philosophy and pedagogical approach</li><li>Specific challenges you face in your current teaching environment</li><li>Your personal goals and expected outcomes from this coaching program</li><li>Share your institution’s AI Policy and ethical guidelines</li><li>Any institutional policies or constraints regarding AI use</li></ul><p><br></p><p><strong>Purpose:</strong> This foundational step allows me to design a completely personalized coaching experience. I analyze your context to prepare custom resources, examples, and strategies that directly address your teaching reality.</p>','assignment',1,0,'2025-10-10 01:50:56','2025-10-10 01:50:56'),
(247,10,2,'Vision Alignment & AI Foundations (Live Coaching Session 1 - Week 3)','<p><strong>Duration:</strong> 60-minute live session</p><p><strong>Type:</strong> Live 1 on 1 Coaching</p><p><strong>Meeting Required:</strong> Yes - you must book a convenient meeting time in my calendar.</p><p><br></p><p><strong>﻿What We\'ll Cover:</strong></p><ul><li>Deep dive into your teaching context and aspirations</li><li>Clarifying your program goals and defining success metrics</li><li>Demystifying AI: What it can and cannot do in education</li><li>The changing role of the educator: From information deliverer to learning architect</li><li>Ethical considerations and responsible AI use in your specific context</li><li>Introduction to the AI integration framework customized for your teaching level</li><li>Personalized tool recommendations based on your institutional permissions</li><li>Setting up your AI experimentation environment</li></ul><p><br></p><p><strong>Outcomes:</strong> You leave with clarity on your transformation journey, a customized AI toolkit, and confidence in the ethical framework guiding your experiments.</p>','session',3,1,'2025-10-10 01:50:56','2025-10-10 01:50:56'),
(248,10,3,'Experimentation Lab - Administrative Efficiency (Self-Paced Experience - Weeks 3-5)','<p><strong>Duration:</strong> 2 weeks</p><p><strong>Type:</strong> Assignment</p><p><strong>Meeting Required:</strong> No</p><p><br></p><p><strong>What You\'ll Do Based on Our First Meeting:</strong></p><ul><li>Implement AI tools for at least 3 administrative tasks (email management, lesson planning, resource curation, or meeting summaries)</li><li>Experiment with AI-assisted curriculum design for an upcoming unit or module</li><li>Create a time-tracking log documenting hours saved</li><li>Develop initial templates and prompts (targeted prompting relevant to your goals) that work for your specific needs</li><li>Document challenges, breakthroughs, and questions</li></ul><p><br></p><p><strong>What You\'ll Submit:</strong></p><ul><li>Selected AI tools used and why those tools were chosen</li><li>Detailed experience report with specific examples of AI applications</li><li>Before/after comparisons of time spent on administrative tasks</li><li>Sample AI-generated outputs you created (lesson plans, communication templates, etc.)</li><li>Reflections on what worked, what didn\'t, and what surprised you</li><li>Questions and challenges for refinement in the next live session</li></ul><p><br></p><p><strong>Purpose:</strong> Build confidence through hands-on experimentation in low-stakes applications while reclaiming valuable time.</p>','assignment',5,0,'2025-10-10 01:50:56','2025-10-10 01:50:56'),
(249,10,4,'Refinement & Pedagogical Integration (Live Coaching Session 2 - Week 6)','<p><strong>Duration:</strong> 60-minute live session</p><p><strong>Type:</strong> Live 1 on 1 Coaching</p><p><strong>Meeting Required:</strong> Yes - you must book a convenient meeting time in my calendar.</p><p><br></p><p><strong>﻿What We\'ll Cover:</strong></p><ul><li>Detailed debrief of your administrative AI experiments</li><li>Troubleshooting challenges and optimizing your workflows</li><li>Moving beyond efficiency: AI as a pedagogical partner</li><li>Designing AI-enhanced learning experiences for your students</li><li>Differentiation strategies: Using AI to personalize instruction at scale</li><li>Assessments that measure deeper learning if the majority are using AI</li><li>Student engagement techniques in an AI-transparent classroom</li><li>Planning your classroom AI integration pilot</li></ul><p><br></p><p><strong>Outcomes:</strong> You transition from using AI for yourself to integrating it into your teaching practice, with a concrete plan for a classroom pilot.</p>','session',6,1,'2025-10-10 01:50:56','2025-10-10 01:50:56'),
(250,10,5,'Classroom Integration Pilot (Self-Paced Experience - Weeks 6-8)','<p><strong>Duration:</strong> 2 weeks</p><p><strong>Type:</strong> Assignment</p><p><strong>Meeting Required:</strong> No</p><p><br></p><p><strong>What You\'ll Do:</strong></p><ul><li>Implement at least one AI-integrated learning experience with your students</li><li>Design and deploy an AI-assisted assessment or feedback mechanism</li><li>Experiment with personalization strategies using AI insights</li><li>Facilitate a classroom discussion about AI ethics and responsible use (age-appropriate)</li><li>Gather student feedback on their learning experience</li><li>Document the complete cycle: planning, implementation, student response, and outcomes</li></ul><p><br></p><p><strong>What You\'ll Submit:</strong></p><ul><li>Comprehensive case study of your classroom pilot including lesson design, student work samples (anonymized), and outcome data</li><li>Student feedback summary and analysis</li><li>Personal reflections on what you learned about facilitation in an AI-integrated environment</li><li>Challenges encountered and creative solutions you developed</li><li>Questions about scaling or refining your approach</li></ul><p><br></p><p><strong>Purpose:</strong> Transform from AI experimenter to AI-integrated educator through real classroom application and student-centered learning.</p>','assignment',6,0,'2025-10-10 01:50:56','2025-10-10 01:50:56'),
(251,10,6,'Facilitation Mastery & Advanced Strategies (Live Coaching Session 3 - Week 9)','<p><strong>Duration:</strong> 60-minute live session</p><p><strong>Type:</strong> Live 1 on 1 Coaching</p><p><strong>Meeting Required:</strong> Yes - you must book a convenient meeting time in my calendar.</p><p><br></p><p><strong>What We\'ll Cover:</strong></p><ul><li>In-depth analysis of your classroom pilot results</li><li>Celebrating successes and extracting transferable insights</li><li>Advanced facilitation techniques for AI-augmented learning environments</li><li>Addressing student over-reliance and building critical AI literacy</li><li>Redesigning assessments for the AI era: Moving beyond detection to authentic evaluation</li><li>Creating sustainable AI integration systems that don\'t burn you out</li><li>Strategic planning for full curriculum integration (depends on the educator being coached; it may or may not be part of the program)</li></ul><p><br></p><p><strong>Outcomes:</strong> You gain advanced facilitation skills, sustainable implementation strategies, and a roadmap for expanding AI integration in areas of your life and career that you choose.</p>','session',9,1,'2025-10-10 01:50:56','2025-10-10 01:50:56'),
(252,10,7,'Full Implementation & Mastery Demonstration (Self-Paced Experience - Weeks 9-10)','<p><strong>Duration:</strong> 2 weeks</p><p><strong>Type:</strong> Assignment</p><p><strong>Meeting Required:</strong> No</p><p><br></p><p><strong>What You\'ll Do:</strong></p><ul><li>Implement AI integration across selected areas of your life or career where you want to collaborate with AI</li><li>Experiment with one cutting-edge approach we discussed (AI tutors, collaborative AI projects, adaptive learning paths, etc.)</li><li>Mentor or share your new proposed approach with a colleague (if comfortable)</li><li>Create your personal AI integration playbook documenting your methods, favorite prompts, and best practices</li><li>Reflect on your journey from the program start to now.</li></ul><p><br></p><p><strong>What You\'ll Submit:</strong></p><ul><li>Your complete AI Integration Playbook (customized to your teaching context)</li><li>Evidence of expanded implementation (selected shareable work)</li><li>Documentation of your most advanced AI application experiment</li><li>Reflection on your professional transformation: What\'s changed in how you view AI, how you teach, think, and plan</li><li>Preparation for final debrief: insights you want to discuss, lingering questions, future goals</li></ul><p><br></p><p><strong>Purpose:</strong> Consolidate your learning into a sustainable, scalable practice that demonstrates mastery and positions you as an educational leader.</p>','assignment',9,0,'2025-10-10 01:50:56','2025-10-10 01:50:56'),
(253,10,8,'Celebration, Reflection & Future Pathways (Live Coaching Session 4 - Week 12)','<p><strong>Duration:</strong> 60-minute live session</p><p><strong>Type:</strong> Live 1 on 1 Coaching</p><p><strong>Meeting Required:</strong> Yes - you must book a convenient meeting time in my calendar.</p><p><br></p><p><strong>What We\'ll Cover:</strong></p><ul><li>Comprehensive program debrief and celebration of your transformation</li><li>Analysis of your before/after teaching practice and professional confidence</li><li>Reflection on your most significant learnings and breakthrough moments</li><li>Identification of ongoing development areas and future learning goals</li><li>Strategies for staying current as AI tools and educational practices evolve</li><li>Building your professional network and leadership opportunities in AI education</li><li>Creating your personalized 12-month post-program development plan</li><li>Honest feedback: Did this program deliver value? What would have made it better?</li><li>Does your employer sponsor such programs?</li><li>Next steps? I am listening to you.</li></ul><p><br></p><p><strong>Outcomes:</strong> You complete the program with clarity on your continued growth path, recognition of your transformation, and a concrete plan for maintaining momentum and expanding your impact.</p>','session',12,1,'2025-10-10 01:50:56','2025-10-10 01:50:56'),
(266,11,1,'Incorporation','<p>ff</p>','assignment',1,0,'2025-10-10 12:15:01','2025-10-10 12:15:01'),
(267,12,1,'Bus Plan','<p>	fggg</p>','assignment',1,0,'2025-10-11 18:20:06','2025-10-11 18:20:06'),
(268,12,2,'Face Face','<p>FF</p>','session',4,1,'2025-10-11 18:20:06','2025-10-11 18:20:06'),
(293,6,1,'Homework 1 (Weeks 2–3): Startup Snapshot & Current Challenge','<ul><li><strong>Founder task:</strong> Share <strong>pitch deck draft, mission, vision, milestones to date, and biggest challenge now</strong>.</li><li><strong>Result:</strong> Norman gets a full picture to tailor guidance. Founder gets clarity on what they want to achieve.</li></ul>','assignment',2,0,'2025-10-13 17:16:43','2025-10-13 17:16:43'),
(294,6,2,'Live Session 1 (Week 4): Diagnosis & Priorities','<ul><li><strong>Activity:</strong> Review pitch deck, milestones, and team composition.</li><li><strong>Result:</strong> Clear <strong>diagnosis of gaps</strong> (product clarity, market focus, or funding prep) and a <strong>30-day action plan</strong> focused on product development/validation.</li></ul>','session',4,1,'2025-10-13 17:16:43','2025-10-13 17:16:43'),
(295,6,3,'Homework 2 (Weeks 5–6): Customer Validation & Product Testing','<ul><li><strong>Founder task:</strong> Conduct <strong>customer discovery or MVP testing</strong> (interviews, surveys, pilot runs).</li><li><strong>Result:</strong> Founders collect <strong>real customer insights</strong>, refine product features, and validate demand.</li></ul>','assignment',6,0,'2025-10-13 17:16:43','2025-10-13 17:16:43'),
(296,6,4,'Live Session 2 (Week 7): Go-to-Market & Funding Prep','<ul><li><strong>Activity:</strong> Use insights to refine <strong>business model, pricing, and go-to-market strategy</strong>. Introduce <strong>funding options</strong> (bootstrapping, grants, angels, VCs).</li><li><strong>Result:</strong> Founders leave with a <strong>tested GTM plan</strong> and a draft <strong>funding strategy</strong> matched to their stage.</li></ul>','session',8,1,'2025-10-13 17:16:43','2025-10-13 17:16:43'),
(297,6,5,'Homework 3 (Weeks 8–10): Traction & Business Plan Build','<ul><li><strong>Founder task:</strong> Document <strong>traction data</strong> (early adopters, sign-ups, pilots, letters of intent) + build a <strong>draft business plan</strong> (vision, model, financial assumptions).</li><li><strong>Result:</strong> Founders gain <strong>concrete evidence of traction</strong> and a structured business plan to guide growth.</li></ul>','assignment',10,0,'2025-10-13 17:16:43','2025-10-13 17:16:43'),
(298,6,6,'Live Session 3 (Week 11–12): Investor & Roadmap Readiness','<ul><li><strong>Activity:</strong> Review traction, business plan, and funding strategy. Refine <strong>pitch deck storytelling</strong>.</li><li><strong>Result:</strong> Founders leave with a <strong>90-day action roadmap</strong>, an <strong>investor-ready pitch deck</strong>, and a <strong>solid tailored funding strategy</strong>.</li></ul>','session',12,1,'2025-10-13 17:16:43','2025-10-13 17:16:43');
/*!40000 ALTER TABLE `coaching_template_steps` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `contact_messages`
--

DROP TABLE IF EXISTS `contact_messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `contact_messages` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `full_name` varchar(160) NOT NULL,
  `email` varchar(190) NOT NULL,
  `phone` varchar(60) DEFAULT NULL,
  `topic` varchar(60) NOT NULL DEFAULT 'support',
  `subject` varchar(190) DEFAULT NULL,
  `message` text NOT NULL,
  `consent` tinyint(1) NOT NULL DEFAULT 0,
  `page` varchar(80) NOT NULL DEFAULT 'contact',
  `ip_address` varchar(64) DEFAULT NULL,
  `user_agent` varchar(255) DEFAULT NULL,
  `status` enum('new','read','archived') NOT NULL DEFAULT 'new',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_email_created` (`email`,`created_at`),
  KEY `idx_status_created` (`status`,`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `contact_messages`
--

LOCK TABLES `contact_messages` WRITE;
/*!40000 ALTER TABLE `contact_messages` DISABLE KEYS */;
/*!40000 ALTER TABLE `contact_messages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `course_categories`
--

DROP TABLE IF EXISTS `course_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `course_categories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `course_id` int(11) NOT NULL,
  `category_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_course_category` (`course_id`,`category_id`),
  KEY `idx_cc_course` (`course_id`),
  KEY `idx_cc_category` (`category_id`),
  CONSTRAINT `fk_cc_category` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_cc_course` FOREIGN KEY (`course_id`) REFERENCES `courses` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `course_categories`
--

LOCK TABLES `course_categories` WRITE;
/*!40000 ALTER TABLE `course_categories` DISABLE KEYS */;
INSERT INTO `course_categories` VALUES
(3,5,14,'2025-08-16 21:45:44');
/*!40000 ALTER TABLE `course_categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `course_category_map`
--

DROP TABLE IF EXISTS `course_category_map`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `course_category_map` (
  `course_id` int(11) NOT NULL,
  `category_id` int(11) NOT NULL,
  PRIMARY KEY (`course_id`,`category_id`),
  KEY `idx_ccm_category` (`category_id`),
  CONSTRAINT `fk_ccm_category` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_ccm_course` FOREIGN KEY (`course_id`) REFERENCES `courses` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `course_category_map`
--

LOCK TABLES `course_category_map` WRITE;
/*!40000 ALTER TABLE `course_category_map` DISABLE KEYS */;
/*!40000 ALTER TABLE `course_category_map` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `course_enrollments`
--

DROP TABLE IF EXISTS `course_enrollments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `course_enrollments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `course_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `enrolled_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `completed_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `course_id` (`course_id`),
  KEY `user_id` (`user_id`),
  KEY `idx_enroll_course_created` (`course_id`,`enrolled_at`),
  CONSTRAINT `course_enrollments_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `courses` (`id`) ON DELETE CASCADE,
  CONSTRAINT `course_enrollments_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `course_enrollments`
--

LOCK TABLES `course_enrollments` WRITE;
/*!40000 ALTER TABLE `course_enrollments` DISABLE KEYS */;
INSERT INTO `course_enrollments` VALUES
(2,5,1,'2025-08-16 18:49:42',NULL),
(3,5,1,'2025-08-16 18:49:46',NULL),
(4,5,2,'2025-09-07 15:44:51',NULL),
(5,4,2,'2025-09-07 16:03:58',NULL),
(6,5,2,'2025-09-07 16:15:23',NULL),
(7,5,2,'2025-09-07 16:38:35',NULL),
(8,5,2,'2025-09-07 16:38:50',NULL),
(9,14,2,'2025-09-07 16:55:19',NULL),
(10,14,2,'2025-09-07 17:30:18',NULL),
(11,14,2,'2025-09-07 17:32:17',NULL),
(12,14,2,'2025-09-07 17:34:15',NULL),
(13,14,2,'2025-09-07 17:39:59',NULL),
(14,19,3,'2025-09-25 10:02:45',NULL),
(15,17,3,'2025-09-27 09:25:44',NULL),
(16,18,3,'2025-10-05 07:32:29',NULL);
/*!40000 ALTER TABLE `course_enrollments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `course_features`
--

DROP TABLE IF EXISTS `course_features`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `course_features` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `course_id` int(11) NOT NULL,
  `feature_type` enum('text','image','pdf') NOT NULL,
  `feature_value` text DEFAULT NULL,
  `content` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `course_id` (`course_id`),
  CONSTRAINT `course_features_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `courses` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `course_features`
--

LOCK TABLES `course_features` WRITE;
/*!40000 ALTER TABLE `course_features` DISABLE KEYS */;
/*!40000 ALTER TABLE `course_features` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `course_files`
--

DROP TABLE IF EXISTS `course_files`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `course_files` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `course_id` int(11) DEFAULT NULL,
  `file_name` varchar(255) DEFAULT NULL,
  `file_type` varchar(50) DEFAULT NULL,
  `file_path` text DEFAULT NULL,
  `uploaded_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `course_id` (`course_id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `course_files`
--

LOCK TABLES `course_files` WRITE;
/*!40000 ALTER TABLE `course_files` DISABLE KEYS */;
INSERT INTO `course_files` VALUES
(1,1,'32-HCL-Technologies-Denmark-Apps_0 (1).pdf','application/pdf','uploads\\course_materials\\1753465705488-32-HCL-Technologies-Denmark-Apps_0 (1).pdf','2025-07-25 17:48:25'),
(2,1,'32-HCL-Technologies-Denmark-Apps_0 (1).pdf','application/pdf','uploads\\course_materials\\1754504043452-32-HCL-Technologies-Denmark-Apps_0 (1).pdf','2025-08-06 18:14:03'),
(3,3,'Sales Invoice - 1010.pdf','application/pdf','uploads/course_materials/1755332683112-Sales Invoice - 1010.pdf','2025-08-16 08:24:43'),
(4,5,'Maysha MalihaÂ Mou ( Borrower).pdf','application/pdf','/uploads/courses/materials/1755347566826-maysha-maliha-mou-borrower.pdf','2025-08-16 12:32:46'),
(5,5,'Invoice-LMCAZGIW-0001.pdf','application/pdf','/uploads/courses/materials/1755358147449-invoice-lmcazgiw-0001.pdf','2025-08-16 15:29:07'),
(6,5,'Invoice-LMCAZGIW-0001.pdf','application/pdf','/uploads/courses/materials/1755359167008-invoice-lmcazgiw-0001.pdf','2025-08-16 15:46:07'),
(7,14,'Invoice-NHR24TMQ-0001 (1).pdf','application/pdf','/uploads/courses/materials/1755443380731-invoice-nhr24tmq-0001-1.pdf','2025-08-17 15:09:40'),
(8,14,'Receipt-2168-1384.pdf','application/pdf','/uploads/courses/materials/1755443380783-receipt-2168-1384.pdf','2025-08-17 15:09:40'),
(9,18,'Please note that not all the checklist items will apply to everyone.pdf','application/pdf','/uploads/courses/materials/1757771397069-please-note-that-not-all-the-checklist-items-will-apply-to-everyone.pdf','2025-09-13 13:49:57'),
(10,19,'top11.png','image/png','/uploads/courses/materials/1757853476602-top11.png','2025-09-14 12:37:56');
/*!40000 ALTER TABLE `course_files` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `course_lessons`
--

DROP TABLE IF EXISTS `course_lessons`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `course_lessons` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `course_id` int(11) NOT NULL,
  `title` varchar(200) NOT NULL,
  `description` text DEFAULT NULL,
  `video_url` varchar(255) DEFAULT NULL,
  `is_free` tinyint(1) NOT NULL DEFAULT 0,
  `order_no` int(11) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `course_id` (`course_id`,`order_no`),
  CONSTRAINT `course_lessons_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `courses` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `course_lessons`
--

LOCK TABLES `course_lessons` WRITE;
/*!40000 ALTER TABLE `course_lessons` DISABLE KEYS */;
INSERT INTO `course_lessons` VALUES
(1,5,'Introduction','Welcome to the course!','',1,1,'2025-08-16 12:13:11','2025-08-16 12:13:11'),
(2,5,'breaf','Hi\ngfgfdh','https://www.facebook.com',0,2,'2025-08-16 12:13:11','2025-08-16 12:13:11'),
(3,5,'Introduction','Welcome to the course!','',1,1,'2025-08-16 15:28:57','2025-08-16 15:28:57'),
(4,5,'breaf','Hi\ngfgfdh','https://www.facebook.com',0,2,'2025-08-16 15:28:57','2025-08-16 15:28:57'),
(5,5,'Introduction','Welcome to the course!','',1,1,'2025-08-16 15:31:52','2025-08-16 15:31:52'),
(6,5,'Introduction','Welcome to the course!','',1,2,'2025-08-16 15:31:52','2025-08-16 15:31:52'),
(7,5,'breaf','Hi\ngfgfdh','https://www.facebook.com',1,3,'2025-08-16 15:31:52','2025-08-16 15:31:52'),
(8,5,'breaf','Hi\ngfgfdh','https://www.facebook.com',0,4,'2025-08-16 15:31:52','2025-08-16 15:31:52'),
(9,5,'Introduction','Welcome to the course!','',1,1,'2025-08-16 15:45:55','2025-08-16 15:45:55'),
(10,5,'Introduction','Welcome to the course!','',1,2,'2025-08-16 15:45:55','2025-08-16 15:45:55'),
(11,5,'Introduction','Welcome to the course!','',1,3,'2025-08-16 15:45:55','2025-08-16 15:45:55'),
(12,5,'breaf','Hi\ngfgfdh','https://www.facebook.com',0,4,'2025-08-16 15:45:55','2025-08-16 15:45:55'),
(13,5,'breaf','Hi\ngfgfdh','https://www.facebook.com',0,5,'2025-08-16 15:45:55','2025-08-16 15:45:55'),
(14,5,'Introduction','Welcome to the course!','',1,6,'2025-08-16 15:45:55','2025-08-16 15:45:55'),
(15,5,'breaf','Hi\ngfgfdh','https://www.facebook.com',1,7,'2025-08-16 15:45:55','2025-08-16 15:45:55'),
(16,5,'breaf','Hi\ngfgfdh','https://www.facebook.com',0,8,'2025-08-16 15:45:55','2025-08-16 15:45:55'),
(17,14,'Introduction','Welcome to the course!','https://www.youtube.com/watch?v=hZEm3gQ7jwI',1,1,'2025-08-17 15:09:08','2025-08-17 15:09:08'),
(18,14,'New Lesson 2','This thsi isdfgfdh gjshfk','',0,2,'2025-08-17 15:09:08','2025-08-17 15:09:08'),
(19,14,'New Lesson','This thsi isdfgfdh gjshfk','',0,3,'2025-08-17 15:09:08','2025-08-17 15:09:08'),
(20,17,'Introduction','Welcome to the course!','',1,1,'2025-09-13 08:33:59','2025-09-13 08:33:59'),
(21,18,'A lived experience description of how one finds the right job opportunities for themselves in new countries for newcomers.','A Newcomer\'s Guide to Finding Your First Right Job\nLanding your first job in a new country can feel like searching for a needle in a haystack—but it doesn\'t have to be. This lesson takes you beyond generic job search advice and into the real, lived experience of finding the right career path as a newcomer.\n\nWe\'ll share practical, relatable strategies and insights from those who have successfully navigated this journey. You’ll learn how to overcome common obstacles, leverage your unique background, and build a career that aligns with your goals and values in your new home.\n\n3 Reasons to Take This Lesson Now\nStop Wasting Time on the Wrong Jobs. This lesson isn\'t just about finding any job; it\'s about finding the right job for you. We\'ll help you identify positions that align with your skills, values, and long-term career goals, saving you from the frustration of a job that doesn\'t fit.\n\nLearn from Real-World Experience. Forget the generic advice you can find online. We share a personal, lived experience approach, offering actionable insights and proven strategies from someone who has been in your shoes. This is a chance to learn what really works and what doesn\'t.\n\nBuild a Career, Not Just a Paycheck. Your international experience and unique perspective are valuable assets. This lesson will show you how to effectively showcase your background to employers, helping you secure a role where you can truly thrive and build a meaningful career in your new country.','https://youtu.be/h9-mVcvbGuY',0,1,'2025-09-13 13:34:52','2025-09-13 13:34:52'),
(22,18,'A lived experience description of how one finds the right job opportunities for themselves in new countries for newcomers.','A Newcomer\'s Guide to Finding Your First Right Job\nLanding your first job in a new country can feel like searching for a needle in a haystack—but it doesn\'t have to be. This lesson takes you beyond generic job search advice and into the real, lived experience of finding the right career path as a newcomer.\n\nWe\'ll share practical, relatable strategies and insights from those who have successfully navigated this journey. You’ll learn how to overcome common obstacles, leverage your unique background, and build a career that aligns with your goals and values in your new home.\n\n3 Reasons to Take This Lesson Now\nStop Wasting Time on the Wrong Jobs. This lesson isn\'t just about finding any job; it\'s about finding the right job for you. We\'ll help you identify positions that align with your skills, values, and long-term career goals, saving you from the frustration of a job that doesn\'t fit.\n\nLearn from Real-World Experience. Forget the generic advice you can find online. We share a personal, lived experience approach, offering actionable insights and proven strategies from someone who has been in your shoes. This is a chance to learn what really works and what doesn\'t.\n\nBuild a Career, Not Just a Paycheck. Your international experience and unique perspective are valuable assets. This lesson will show you how to effectively showcase your background to employers, helping you secure a role where you can truly thrive and build a meaningful career in your new country.','https://youtu.be/h9-mVcvbGuY',0,1,'2025-09-13 14:20:31','2025-09-13 14:20:31'),
(23,19,'Introduction','Welcome to the course!','https://www.youtube.com/',0,1,'2025-09-14 12:37:40','2025-09-14 12:37:40');
/*!40000 ALTER TABLE `course_lessons` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `course_materials`
--

DROP TABLE IF EXISTS `course_materials`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `course_materials` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `course_id` int(11) NOT NULL,
  `lesson_id` int(11) DEFAULT NULL,
  `title` varchar(200) NOT NULL,
  `file_path` varchar(255) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `course_id` (`course_id`),
  KEY `lesson_id` (`lesson_id`),
  CONSTRAINT `course_materials_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `courses` (`id`) ON DELETE CASCADE,
  CONSTRAINT `course_materials_ibfk_2` FOREIGN KEY (`lesson_id`) REFERENCES `course_lessons` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `course_materials`
--

LOCK TABLES `course_materials` WRITE;
/*!40000 ALTER TABLE `course_materials` DISABLE KEYS */;
/*!40000 ALTER TABLE `course_materials` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `course_orders`
--

DROP TABLE IF EXISTS `course_orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `course_orders` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `course_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `currency` varchar(10) NOT NULL DEFAULT 'usd',
  `provider` enum('stripe','paypal') NOT NULL DEFAULT 'stripe',
  `status` enum('pending','paid','failed','refunded') NOT NULL DEFAULT 'pending',
  `cancelled_at` datetime DEFAULT NULL,
  `cancelled_by` int(11) DEFAULT NULL,
  `cancelled_reason` varchar(255) DEFAULT NULL,
  `provider_session_id` varchar(191) DEFAULT NULL,
  `provider_payment_id` varchar(191) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `provider_payment_intent_id` varchar(255) DEFAULT NULL,
  `provider_charge_id` varchar(255) DEFAULT NULL,
  `provider_invoice_id` varchar(255) DEFAULT NULL,
  `payment_method_id` varchar(255) DEFAULT NULL,
  `receipt_url` text DEFAULT NULL,
  `hosted_invoice_url` text DEFAULT NULL,
  `invoice_pdf_url` text DEFAULT NULL,
  `card_brand` varchar(32) DEFAULT NULL,
  `card_last4` varchar(8) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_user_course` (`user_id`,`course_id`),
  KEY `course_id` (`course_id`),
  KEY `idx_course_orders_provider_session` (`provider_session_id`),
  CONSTRAINT `course_orders_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `courses` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=30 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `course_orders`
--

LOCK TABLES `course_orders` WRITE;
/*!40000 ALTER TABLE `course_orders` DISABLE KEYS */;
INSERT INTO `course_orders` VALUES
(1,5,1,20.00,'usd','stripe','paid',NULL,NULL,NULL,'cs_test_a1c8615v1AvHRfG1Qz60ObOoCcPRKPlxKPGFPnAGaTSgo6cZOZyrINspkY',NULL,'2025-08-16 16:33:10','2025-08-19 12:21:16','pi_3RwpAf3RqEMUJuhk0olhjg8r','ch_3RwpAf3RqEMUJuhk0qL72Jpw',NULL,'pm_1RwpAe3RqEMUJuhkKbw2Kgvn','https://pay.stripe.com/receipts/payment/CAcaFwoVYWNjdF8xUnZ6bW0zUnFFTVVKdWhrKMelg8UGMgafYtUBTsM6LBYsKXon2CVykaVSAjCDiGipegx4eynm30SqyTnIZOPRW11RMOCrG_5lrKrI',NULL,NULL,'visa','4242'),
(5,14,2,20.00,'usd','stripe','paid',NULL,NULL,NULL,'cs_test_a1nbshAaE6tRzZ53Bn6jCHJ5aMl5UIWBiGvsNEu6A4IYgyjWc3fuwAjyaC','pi_3S4jk63RqEMUJuhk0iroMgQy','2025-09-07 12:30:13','2025-09-07 17:39:59','pi_3S4jk63RqEMUJuhk0iroMgQy','ch_3S4jk63RqEMUJuhk0wtg1rQk',NULL,NULL,'https://pay.stripe.com/receipts/invoices/CAcaFwoVYWNjdF8xUnZ6bW0zUnFFTVVKdWhrKO-G98UGMgZ6CttbkW06LBYYlcoJNYFcpQ15DSzCEUufBdqB_5Nr2ZQdBcCn3GzO6-KYh5TYmVYNqjIL?s=ap','https://invoice.stripe.com/i/acct_1Rvzmm3RqEMUJuhk/test_YWNjdF8xUnZ6bW0zUnFFTVVKdWhrLF9UMGxHeFRpdmRzbGJoMU9CRzlUT2VFOFRsUXhxNGtvLDE0NzgwNzU5OQ0200Mr3hdXrX?s=ap','https://pay.stripe.com/invoice/acct_1Rvzmm3RqEMUJuhk/test_YWNjdF8xUnZ6bW0zUnFFTVVKdWhrLF9UMGxHeFRpdmRzbGJoMU9CRzlUT2VFOFRsUXhxNGtvLDE0NzgwNzU5OQ0200Mr3hdXrX/pdf?s=ap','visa','4242'),
(7,5,2,20.00,'usd','stripe','paid',NULL,NULL,NULL,'cs_test_a1XZmjvTOYWrRCD4r7nUaIiAx5vZmZFxwpAOkYD0f4N1kJcPPxxw1BGvhv','pi_3S4kgP3RqEMUJuhk0Y9th0AI','2025-09-07 13:14:33','2025-09-07 16:38:50','pi_3S4kgP3RqEMUJuhk0Y9th0AI','ch_3S4kgP3RqEMUJuhk08PQBSXe',NULL,NULL,'https://pay.stripe.com/receipts/invoices/CAcaFwoVYWNjdF8xUnZ6bW0zUnFFTVVKdWhrKJrq9sUGMgYWC9YX12g6LBZR3rBLvyGze-ASxnaVBs1GbflH7j9sqe35HHFcrzUtWt-xvqA99IjUFsvI?s=ap','https://invoice.stripe.com/i/acct_1Rvzmm3RqEMUJuhk/test_YWNjdF8xUnZ6bW0zUnFFTVVKdWhrLF9UMG1FSm92QVowTG42VHpPTEZ1aW0ycUNOMGhuWGhnLDE0NzgwMzkzMA0200niTxx5S6?s=ap','https://pay.stripe.com/invoice/acct_1Rvzmm3RqEMUJuhk/test_YWNjdF8xUnZ6bW0zUnFFTVVKdWhrLF9UMG1FSm92QVowTG42VHpPTEZ1aW0ycUNOMGhuWGhnLDE0NzgwMzkzMA0200niTxx5S6/pdf?s=ap','visa','4242'),
(13,4,2,49.00,'usd','stripe','pending',NULL,NULL,NULL,NULL,'pi_3S4k8b3RqEMUJuhk0RdaVUio','2025-09-07 15:03:50','2025-09-28 10:09:51','pi_3S4k8b3RqEMUJuhk0RdaVUio','ch_3S4k8b3RqEMUJuhk0fdRgANZ',NULL,NULL,'https://pay.stripe.com/receipts/invoices/CAcaFwoVYWNjdF8xUnZ6bW0zUnFFTVVKdWhrKO7Z9sUGMgYQQkeLHHw6LBYG6faGYU0ySEJJYgKEV8Y8dYZkaL5ivlxXCjgiu1nhWFFdRlFRnl_NZ1V_?s=ap','https://invoice.stripe.com/i/acct_1Rvzmm3RqEMUJuhk/test_YWNjdF8xUnZ6bW0zUnFFTVVKdWhrLF9UMGxnNVl6ZWxwb25vWVg5bWozWGJHcmZsSWJ3QmtiLDE0NzgwMTgzOA0200t4mp0cFw?s=ap','https://pay.stripe.com/invoice/acct_1Rvzmm3RqEMUJuhk/test_YWNjdF8xUnZ6bW0zUnFFTVVKdWhrLF9UMGxnNVl6ZWxwb25vWVg5bWozWGJHcmZsSWJ3QmtiLDE0NzgwMTgzOA0200t4mp0cFw/pdf?s=ap','visa','4242'),
(18,5,9,20.00,'usd','stripe','pending',NULL,NULL,NULL,NULL,NULL,'2025-09-13 07:37:33','2025-09-13 07:37:42',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
(20,18,3,11.00,'usd','stripe','paid',NULL,NULL,NULL,'cs_test_a1BfeqH0dRK8cm7lnq8BkH3KQfosYHQirQUsZmVH1kEuXvvyKgVSmxHGxL','pi_3SEmOk3RqEMUJuhk1a8OE5hj','2025-09-25 09:56:08','2025-10-05 07:32:29','pi_3SEmOk3RqEMUJuhk1a8OE5hj','ch_3SEmOk3RqEMUJuhk1yTztWUq',NULL,NULL,'https://pay.stripe.com/receipts/invoices/CAcaFwoVYWNjdF8xUnZ6bW0zUnFFTVVKdWhrKIy-iMcGMgZMefawde46LBadqa1fSz73Vixj2tCaMEsGLpzjgafvQ-WiJtvF-VtMO35GNio06U3d6YUn?s=ap','https://invoice.stripe.com/i/acct_1Rvzmm3RqEMUJuhk/test_YWNjdF8xUnZ6bW0zUnFFTVVKdWhrLF9UQjhpd0JsZDVRRTlnWmVmSXltTHI4VGdwNXNqSEpzLDE1MDE5MDM0OQ0200T1wTVGpr?s=ap','https://pay.stripe.com/invoice/acct_1Rvzmm3RqEMUJuhk/test_YWNjdF8xUnZ6bW0zUnFFTVVKdWhrLF9UQjhpd0JsZDVRRTlnWmVmSXltTHI4VGdwNXNqSEpzLDE1MDE5MDM0OQ0200T1wTVGpr/pdf?s=ap',NULL,NULL),
(22,19,3,0.00,'usd','stripe','paid',NULL,NULL,NULL,NULL,NULL,'2025-09-25 10:02:45','2025-09-25 10:02:45',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
(23,17,3,0.00,'usd','stripe','paid',NULL,NULL,NULL,NULL,NULL,'2025-09-27 09:25:44','2025-09-27 09:25:44',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
(26,14,6,20.00,'usd','stripe','pending',NULL,NULL,NULL,NULL,NULL,'2025-09-28 18:41:02','2025-09-28 18:41:02',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
(27,5,6,20.00,'usd','stripe','pending',NULL,NULL,NULL,NULL,NULL,'2025-09-28 18:44:26','2025-09-28 18:44:26',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
(29,14,3,20.00,'usd','stripe','pending',NULL,NULL,NULL,NULL,NULL,'2025-10-09 15:22:39','2025-10-09 15:22:39',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `course_orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `course_progress`
--

DROP TABLE IF EXISTS `course_progress`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `course_progress` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `course_id` int(11) NOT NULL,
  `lesson_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `is_completed` tinyint(1) NOT NULL DEFAULT 0,
  `completed_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_progress` (`user_id`,`course_id`,`lesson_id`),
  KEY `course_id` (`course_id`),
  KEY `lesson_id` (`lesson_id`),
  CONSTRAINT `course_progress_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `courses` (`id`) ON DELETE CASCADE,
  CONSTRAINT `course_progress_ibfk_2` FOREIGN KEY (`lesson_id`) REFERENCES `course_lessons` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=107 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `course_progress`
--

LOCK TABLES `course_progress` WRITE;
/*!40000 ALTER TABLE `course_progress` DISABLE KEYS */;
INSERT INTO `course_progress` VALUES
(1,5,1,1,1,'2025-08-16 20:03:02'),
(2,5,5,1,1,'2025-08-16 20:03:08'),
(3,5,9,1,1,'2025-08-16 20:03:11'),
(4,5,6,1,0,NULL),
(5,5,10,1,0,NULL),
(6,5,7,1,0,NULL),
(7,5,16,1,1,'2025-08-16 20:03:34'),
(8,5,15,1,1,'2025-08-16 20:03:33'),
(9,5,14,1,1,'2025-08-16 20:03:31'),
(10,5,13,1,1,'2025-08-16 20:03:30'),
(11,5,12,1,1,'2025-08-16 20:03:28'),
(12,5,8,1,1,'2025-08-16 20:03:26'),
(13,5,11,1,1,'2025-08-16 20:14:33'),
(17,5,2,1,1,'2025-08-17 14:54:31'),
(20,5,3,1,1,'2025-08-16 20:03:06'),
(55,5,4,1,1,'2025-08-17 14:54:32'),
(101,5,1,2,1,'2025-09-07 15:45:26'),
(102,5,3,2,1,'2025-09-07 15:45:30'),
(103,5,5,2,1,'2025-09-07 15:45:31'),
(104,5,9,2,1,'2025-09-07 15:45:34'),
(105,5,2,2,1,'2025-09-07 15:45:37'),
(106,5,4,2,1,'2025-09-07 15:45:41');
/*!40000 ALTER TABLE `course_progress` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `course_reviews`
--

DROP TABLE IF EXISTS `course_reviews`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `course_reviews` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `course_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `rating` tinyint(3) unsigned NOT NULL,
  `comment` text DEFAULT NULL,
  `review` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_course_user` (`course_id`,`user_id`),
  KEY `course_id` (`course_id`),
  KEY `user_id` (`user_id`),
  KEY `idx_reviews_course_created` (`course_id`,`created_at`),
  CONSTRAINT `course_reviews_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `courses` (`id`) ON DELETE CASCADE,
  CONSTRAINT `course_reviews_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `course_reviews`
--

LOCK TABLES `course_reviews` WRITE;
/*!40000 ALTER TABLE `course_reviews` DISABLE KEYS */;
INSERT INTO `course_reviews` VALUES
(1,5,1,5,'good',NULL,'2025-08-16 19:43:24'),
(2,18,3,5,'Great Norman!',NULL,'2025-10-05 07:33:08');
/*!40000 ALTER TABLE `course_reviews` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `courses`
--

DROP TABLE IF EXISTS `courses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `courses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `slug` varchar(191) NOT NULL,
  `description` text DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `duration` varchar(100) DEFAULT NULL,
  `meet_link` varchar(255) DEFAULT NULL,
  `price` decimal(10,2) DEFAULT 0.00,
  `status` enum('upcoming','ongoing','completed') NOT NULL DEFAULT 'upcoming',
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `course_image` varchar(255) DEFAULT NULL,
  `image_url` text DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `creator_role` int(11) DEFAULT 2,
  `expert_id` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `subtitle` varchar(255) DEFAULT NULL,
  `level` enum('beginner','intermediate','advanced') DEFAULT 'beginner',
  `language` varchar(64) DEFAULT 'English',
  `currency` varchar(16) DEFAULT 'usd',
  `estimated_hours` varchar(32) DEFAULT NULL,
  `visibility` enum('public','unlisted','private') DEFAULT 'public',
  `trailer_url` varchar(255) DEFAULT NULL,
  `publish_state` enum('draft','published','archived') DEFAULT 'draft',
  PRIMARY KEY (`id`),
  UNIQUE KEY `ux_courses_slug` (`slug`),
  KEY `created_by` (`created_by`),
  KEY `idx_courses_active_created` (`is_active`,`created_at`),
  KEY `idx_courses_status_created` (`status`,`created_at`),
  KEY `idx_courses_expert_created` (`expert_id`,`created_at`),
  KEY `idx_courses_price` (`price`),
  KEY `idx_courses_created` (`created_at`),
  FULLTEXT KEY `ft_courses_title_desc` (`title`,`description`),
  CONSTRAINT `courses_ibfk_1` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `courses`
--

LOCK TABLES `courses` WRITE;
/*!40000 ALTER TABLE `courses` DISABLE KEYS */;
INSERT INTO `courses` VALUES
(4,'Professional React Bootcamp','professional-react-bootcamp','<p>Learn React with projects.</p>',NULL,NULL,NULL,NULL,49.00,'upcoming',1,'/uploads/courses/thumbnails/1755345927822-2025-08-15_151724.png',NULL,3,2,3,'2025-08-16 12:05:27',NULL,NULL,NULL,'beginner','English','usd',NULL,'public',NULL,'published'),
(5,'Hello 2','hello','<p>Hi</p><p>Hellow</p>','1899-11-27','1899-11-27','','',20.00,'upcoming',1,'/uploads/courses/thumbnails/1755346349217-2025-08-15_193438.png',NULL,3,2,3,'2025-08-16 12:12:29','2025-08-16 21:46:12',NULL,'hiii','beginner','English','usd','9','public','www/youtube.com','published'),
(14,'Hellow','hellow','<p>Hi</p>','0000-00-00','0000-00-00','','',20.00,'upcoming',1,'/uploads/courses/thumbnails/1755443226730-bg.jpg',NULL,1,2,1,'2025-08-17 15:07:06','2025-08-17 21:09:47',NULL,'fd','beginner','English','usd','8','public','','published'),
(15,'Digital Marketing Masterclass','digital-marketing-masterclass','<p>In this course, you will learn how to build and optimize websites, run digital marketing campaigns, and apply real-world strategies to grow your business.</p>','2025-08-20','2025-08-21','60','https://prosfata.com/experts',90.00,'upcoming',0,'/uploads/courses/thumbnails/1755703407189-191113-happyyoungemployee-stock.jpg',NULL,3,2,3,'2025-08-20 15:23:27',NULL,NULL,'Digital Marketing','beginner','Spanish','usd','2 hours','public','https://prosfata.com/experts','draft'),
(16,'Web Development Beginner to Advanced','web-development-beginner-to-advanced','<p>In this course, you will learn how to build and optimize websites, run digital marketing campaigns, and apply real-world strategies to grow your business.</p>','2025-08-20','2025-08-21','60 mins','https://prosfata.com/experts',0.00,'upcoming',0,'/uploads/courses/thumbnails/1755703858969-online-courses.jpg',NULL,3,2,3,'2025-08-20 15:30:58',NULL,NULL,'Beginner to Advanced','beginner','English','usd','1 hour','public','https://prosfata.com/experts','draft'),
(17,'Full-Stack Armey','full-stack-armey','','2025-10-10','2026-02-05','800','',0.00,'upcoming',1,NULL,NULL,10,2,10,'2025-09-13 08:33:55','2025-09-13 08:34:03',NULL,'This course for beginner friendly for every learner','intermediate','English','usd','72','public','','published'),
(18,'First Steps in Finding Job Opportunities in a New Country - The Canada Newcomer Case Study ','first-steps-in-finding-job-opportunities-in-a-new-country-the-canada-newcomer-case-study','<p>Are you a newcomer to a new country, feeling overwhelmed by the job search process? Do you have skills and experience, but don\'t know how to translate them for the Canadian market? You\'re not alone. The Canadian job landscape has its own unique rules, and navigating them can be a significant challenge. This course is your first step to turning that challenge into a successful career.</p><p>In this comprehensive and practical course, we will walk you through the essential strategies and tools specifically designed for newcomers to new countries. Using a case study approach, you\'ll gain a deep understanding of the Canadian job market and learn how to position yourself as a strong candidate. We\'ll go beyond generic advice to give you actionable insights that get results.</p><p><br></p><p><strong>What You\'ll Learn &amp; What You\'ll Achieve:</strong></p><ul><li><strong>Master the Canadian Resume &amp; Cover Letter:</strong> Learn how to create documents that get past Applicant Tracking Systems (ATS) and impress Canadian recruiters. We\'ll show you how to highlight your international experience and skills in a way that resonates with local employers.</li><li><strong>Build Your Professional Network:</strong> Discover the power of networking in new countries. We\'ll teach you proven strategies for making meaningful connections, conducting informational interviews, and accessing the hidden job market where most positions are filled.</li><li><strong>Navigate the Interview Process:</strong> Gain confidence for your job interviews. We\'ll cover common Canadian interview questions, proper etiquette, and how to effectively tell your professional story to showcase your value.</li><li><strong>Leverage Your Digital Presence:</strong> Optimize your LinkedIn profile and other online tools to attract recruiters and build your professional brand in new countries.</li></ul><p><br></p><p><strong>This course is for you if you are:</strong></p><ul><li>A recent immigrant or permanent resident in a new country.</li><li>An internationally-trained professional or skilled worker.</li><li>Feeling stuck or unsure about your job search strategy.</li><li>Ready to invest in your future and take control of your career path.</li></ul><p><br></p><p><strong>Don\'t let your dream job in new countries remain just a dream. The right strategy can make all the difference. Get started on your path to a successful career today.</strong></p><p><br></p>','2025-09-14','2025-09-29','60 minutes','',11.00,'upcoming',1,'/uploads/courses/thumbnails/1757770299749-ai-generated-1757770248685.jpg',NULL,6,2,6,'2025-09-13 13:31:39','2025-09-13 14:20:38',NULL,'Newcomer job hunting strategies to help them find the first right job opportunities. ','beginner','English','usd','1 Hour','public','https://youtu.be/d6Y0sc77p9s?si=yrSm7Y6KnUV84FT_ ','published'),
(19,'Complete Web Development Bootcamp: Beginner to Pro','complete-web-development-bootcamp-beginner-to-pro','<p>This course is designed to take you from a complete beginner to a confident web developer. You will start with the foundations of web technologies and gradually move toward building full-stack applications. Throughout the journey, you’ll learn how to design responsive websites using HTML, CSS, and JavaScript, and then level up your skills with modern frameworks like React. On the server side, you’ll work with Node.js and Express to handle backend logic, while databases such as MongoDB and MySQL will help you manage data efficiently.</p><p>The course is entirely project-based, ensuring that you gain real-world experience by building practical applications. By the end of the program, you will have your own portfolio of projects, giving you the confidence and credibility to apply for web development jobs or start freelancing as a professional developer.This course is designed to take you from a complete beginner to a confident web developer. You will start with the foundations of web technologies and gradually move toward building full-stack applications. Throughout the journey, you’ll learn how to design responsive websites using HTML, CSS, and JavaScript, and then level up your skills with modern frameworks like React. On the server side, you’ll work with Node.js and Express to handle backend logic, while databases such as MongoDB and MySQL will help you manage data efficiently.</p><p>The course is entirely project-based, ensuring that you gain real-world experience by building practical applications. By the end of the program, you will have your own portfolio of projects, giving you the confidence and credibility to apply for web development jobs or start freelancing as a professional developer.This course is designed to take you from a complete beginner to a confident web developer. You will start with the foundations of web technologies and gradually move toward building full-stack applications. Throughout the journey, you’ll learn how to design responsive websites using HTML, CSS, and JavaScript, and then level up your skills with modern frameworks like React. On the server side, you’ll work with Node.js and Express to handle backend logic, while databases such as MongoDB and MySQL will help you manage data efficiently.</p><p>The course is entirely project-based, ensuring that you gain real-world experience by building practical applications. By the end of the program, you will have your own portfolio of projects, giving you the confidence and credibility to apply for web development jobs or start freelancing as a professional developer.This course is designed to take you from a complete beginner to a confident web developer. You will start with the foundations of web technologies and gradually move toward building full-stack applications. Throughout the journey, you’ll learn how to design responsive websites using HTML, CSS, and JavaScript, and then level up your skills with modern frameworks like React. On the server side, you’ll work with Node.js and Express to handle backend logic, while databases such as MongoDB and MySQL will help you manage data efficiently.</p><p>The course is entirely project-based, ensuring that you gain real-world experience by building practical applications. By the end of the program, you will have your own portfolio of projects, giving you the confidence and credibility to apply for web development jobs or start freelancing as a professional developer.</p>','2025-09-16','2025-09-24','120','',0.00,'upcoming',1,'/uploads/courses/thumbnails/1757853439010-top11.png',NULL,3,2,3,'2025-09-14 12:37:19','2025-09-14 12:37:58',NULL,'Beginner to Pro','beginner','English','usd','2','public','','published');
/*!40000 ALTER TABLE `courses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `expert_education`
--

DROP TABLE IF EXISTS `expert_education`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `expert_education` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `degree` varchar(255) DEFAULT NULL,
  `institution` varchar(255) DEFAULT NULL,
  `graduation_year` year(4) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `idx_expert_education_user` (`user_id`),
  KEY `idx_expert_education_grad` (`graduation_year`),
  CONSTRAINT `expert_education_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `expert_education`
--

LOCK TABLES `expert_education` WRITE;
/*!40000 ALTER TABLE `expert_education` DISABLE KEYS */;
INSERT INTO `expert_education` VALUES
(1,3,'MBA','XYZ University',2018),
(2,6,'Bachelor of Commerce (BCom)','School of Business - Catholic University of Eastern Africa',2100),
(3,6,'MA Leading Innovation and Change (MALIC)','York St John University & Robert Kennedy College',2015),
(4,6,'Master of Management Innovation & Entrepreneurship (MMIE)','Smith School of Business - Queen\'s University',2018);
/*!40000 ALTER TABLE `expert_education` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `expert_experiences`
--

DROP TABLE IF EXISTS `expert_experiences`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `expert_experiences` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `job_title` varchar(255) DEFAULT NULL,
  `company` varchar(255) DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `idx_expert_exp_user` (`user_id`),
  KEY `idx_expert_exp_dates` (`start_date`,`end_date`),
  CONSTRAINT `expert_experiences_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `expert_experiences`
--

LOCK TABLES `expert_experiences` WRITE;
/*!40000 ALTER TABLE `expert_experiences` DISABLE KEYS */;
INSERT INTO `expert_experiences` VALUES
(1,3,'Coach','ABC','2020-01-01','2022-12-31','2025-08-05 17:05:27'),
(2,6,'National Program Director – Business Development Centers','Private Sector Federation (PSF)','2005-11-01','2010-11-30','2025-10-11 19:38:05'),
(3,6,'Rwanda Chapter Manager','Enablis EAC','2011-01-10','2011-06-30','2025-10-11 19:39:19'),
(4,6,'Interim CEO - Confederation of  Danish Industries (DI) Contract','South Sudan Chamber of Commerce, Industry and Agriculture','2012-08-01','2014-05-31','2025-10-11 19:40:41'),
(5,6,'Co - Founder and Managing Associate in Charge of Entrepreneurship and Business Development','Indigo Int. Ltd','2010-05-02','2018-01-31','2025-10-11 19:41:58'),
(6,6,'Student Advisor','Smith School of Business at Queen\'s University · Contract','2020-07-07','2021-09-30','2025-10-11 19:43:54'),
(7,6,'Jim Leech Mastercard Foundation Fellowship Project Coordinator','Dunin-Deshpande Queen\'s Innovation Centre · Contract Full-time','2020-09-16','2022-01-31','2025-10-11 19:45:03'),
(8,6,'Adjunct Professor Entrepreneurship & Business Strategy','St. Lawrence College · Contract Full-time','2020-09-10','2022-04-26','2025-10-11 19:46:06'),
(9,6,'Board Member','Small Business Centres Ontario','2022-08-11','2025-08-30','2025-10-11 19:47:10'),
(10,6,'Member Board of Directors','Black Entrepreneur Ecosystem - South Eastern Ontario','2021-01-19',NULL,'2025-10-11 19:48:01'),
(11,6,'Founder','BizSkills For Good Inc.  BizSkills For Good Inc.','2021-01-31',NULL,'2025-10-11 19:48:44'),
(12,6,'Business Development Manager - Start-ups and Entrepreneurship','Kingston Economic Development Corporation · Permanent Full-time','2020-02-28',NULL,'2025-10-11 19:49:38'),
(13,6,'Chief Executive Officer','Prosfata Inc.','2023-08-30',NULL,'2025-10-11 19:50:46');
/*!40000 ALTER TABLE `expert_experiences` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `expert_languages`
--

DROP TABLE IF EXISTS `expert_languages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `expert_languages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `expert_id` int(11) NOT NULL,
  `language` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `expert_id` (`expert_id`),
  CONSTRAINT `expert_languages_ibfk_1` FOREIGN KEY (`expert_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `expert_languages`
--

LOCK TABLES `expert_languages` WRITE;
/*!40000 ALTER TABLE `expert_languages` DISABLE KEYS */;
INSERT INTO `expert_languages` VALUES
(16,5,'EnglishHindi'),
(22,1,'English'),
(29,3,'English'),
(30,3,'French');
/*!40000 ALTER TABLE `expert_languages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `expert_profile_slug_backup`
--

DROP TABLE IF EXISTS `expert_profile_slug_backup`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `expert_profile_slug_backup` (
  `user_id` int(11) NOT NULL,
  `old_slug` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `old_url` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `backed_up_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `expert_profile_slug_backup`
--

LOCK TABLES `expert_profile_slug_backup` WRITE;
/*!40000 ALTER TABLE `expert_profile_slug_backup` DISABLE KEYS */;
INSERT INTO `expert_profile_slug_backup` VALUES
(3,'expert-3','https://prosfata.space/expert/imran-hossen','2025-10-08 16:55:33'),
(5,'expert-5','https://prosfata.space/expert/mr-alex-joe','2025-10-08 16:55:33'),
(4,'expert-4',NULL,'2025-10-08 16:55:33'),
(1,'expert-1','https://prosfata.space/expert/mohammad-abu-taleb','2025-10-08 16:55:33'),
(6,'norman-musengimana','https://prosfata.space/expert/expert/norman-musengimana','2025-10-08 16:55:33'),
(2,'expert-2',NULL,'2025-10-08 16:55:33'),
(7,'khadiza-khatun','https://prosfata.space/expert/expert/khadiza-khatun','2025-10-08 16:55:33'),
(10,'md-razu-ahamad','https://prosfata.space/expert/expert/md-razu-ahamad','2025-10-08 16:55:33'),
(15,'nashiru-muniru','https://prosfata.space/expert/expert/nashiru-muniru','2025-10-08 16:55:33'),
(16,'anthony-ighomuaye','https://prosfata.space/expert/expert/anthony-ighomuaye','2025-10-08 16:55:33');
/*!40000 ALTER TABLE `expert_profile_slug_backup` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `expert_profiles`
--

DROP TABLE IF EXISTS `expert_profiles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `expert_profiles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `headline` text DEFAULT NULL,
  `bio` text DEFAULT NULL,
  `languages` varchar(255) DEFAULT NULL,
  `graduated` tinyint(1) DEFAULT 0,
  `stripe_account_id` varchar(255) DEFAULT NULL,
  `public_url_slug` varchar(255) NOT NULL,
  `public_profile_url` varchar(255) DEFAULT NULL,
  `total_sessions_completed` int(11) DEFAULT 0,
  `is_verified` tinyint(1) DEFAULT 0,
  `rating_avg` decimal(3,2) NOT NULL DEFAULT 0.00,
  `rating_count` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`),
  UNIQUE KEY `public_url_slug` (`public_url_slug`),
  UNIQUE KEY `idx_expert_profiles_slug` (`public_url_slug`),
  UNIQUE KEY `uq_expert_profiles_public_url_slug` (`public_url_slug`),
  KEY `idx_expert_profiles_public_profile_url` (`public_profile_url`),
  CONSTRAINT `expert_profiles_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=69 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `expert_profiles`
--

LOCK TABLES `expert_profiles` WRITE;
/*!40000 ALTER TABLE `expert_profiles` DISABLE KEYS */;
INSERT INTO `expert_profiles` VALUES
(1,3,'Full-Stack Developer','<p>Uploads <strong>photo first</strong>, then PUTs the JSON payload.</p><p>Keeps <strong>location</strong> in its own textarea so it’s easy to view/edit.</p><p>Prevents accidental nulls by falling back to the GET snapshot for any unset field.</p>','English',0,NULL,'imran-hossen','https://prosfata.space/view/experts/imran-hossen',0,1,0.00,0),
(6,5,'Senior Web Developer','<p>You don’t need to touch your APIs. If you want the “Course” count to be precise, return total_services_offered (or a similar field) in /experts; the card already reads several possible names.</p>',NULL,0,NULL,'mr-alex-joe','https://prosfata.space/view/experts/mr-alex-joe',0,1,0.00,0),
(7,4,NULL,NULL,NULL,0,NULL,'mohammad-abu-taleb-2','https://prosfata.space/view/experts/mohammad-abu-taleb-2',0,0,0.00,0),
(8,1,'','',NULL,0,NULL,'mohammad-abu-taleb','https://prosfata.space/view/experts/mohammad-abu-taleb',0,1,0.00,0),
(42,6,'Expert in Career & Professional Development | Change Strategy | Social Innovation + Entrepreneurship | Innovation Systems |  Economic Development','<h3>Norman Musengimana helps people start right and grow well. A global expert in career and professional development, Change Strategy, social innovation and entrepreneurship, Innovation Systems, and economic development, he designs performance-based programs that turn intention into jobs, ventures, and organizations into industry leaders.</h3><p><br></p><h3>At Kingston Economic Development, Norman advises early-stage founders and internationally trained professionals, pilots new programs, and supports innovation across Ontario’s network—serving on the inaugural Small Business Centres Ontario Board of Directors. He also advises the Southwestern Ontario Black Entrepreneurship Network (SWOBEN). Previously, he led private-sector and entrepreneurship initiatives with the Private Sector Federation of Rwanda and Enablis East Africa, collaborating with partners such as JICA, KOICA, Dansk Industri, etc. to support MSMEs and women-led enterprises in Rwanda and South Sudan.</h3><p><br></p><h3>His Start-Right Framework <strong>(Clarify → Validate → Execute → Scale)</strong> delivers accountable outcomes: He has helped over 700 founders launch and scale their ventures, coached over 100 job seekers, developed more than 20 leadership programs, and delivered over 30 on-the-job training programs for organizations, among many more services.</h3><h3><br></h3><h3>Known for calm, human-first coaching and practical systems design, Norman connects talent, capital, multiculturalism, and institutions so clients can develop targeted strategies and collaborate to develop the right implementation plans as well as follow-up programs.</h3><p><br></p><p>Do you want to become an industry leader? Collaborate with Norman today.</p><p><br></p><p>See you soon!</p><h3><br></h3>',NULL,0,NULL,'norman-musengimana','https://prosfata.space/view/experts/norman-musengimana',0,1,0.00,0),
(51,2,'','',NULL,0,NULL,'mustafizur-rahman','https://prosfata.space/view/experts/mustafizur-rahman',0,1,0.00,0),
(53,7,NULL,NULL,NULL,0,NULL,'khadiza-khatun','https://prosfata.space/view/experts/khadiza-khatun',0,0,0.00,0),
(54,10,'','',NULL,0,NULL,'md-razu-ahamad','https://prosfata.space/view/experts/md-razu-ahamad',0,0,0.00,0),
(66,15,NULL,NULL,NULL,0,NULL,'nashiru-muniru','https://prosfata.space/view/experts/nashiru-muniru',0,1,0.00,0),
(67,16,NULL,NULL,NULL,0,NULL,'anthony-ighomuaye','https://prosfata.space/view/experts/anthony-ighomuaye',0,1,0.00,0),
(68,18,NULL,NULL,NULL,0,NULL,'joshua-wanyonyi','https://prosfata.space/expert/view/experts/joshua-wanyonyi',0,0,0.00,0);
/*!40000 ALTER TABLE `expert_profiles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `expert_reviews`
--

DROP TABLE IF EXISTS `expert_reviews`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `expert_reviews` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `service_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `rating` decimal(2,1) NOT NULL CHECK (`rating` between 1 and 5),
  `review` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_review` (`service_id`,`user_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `expert_reviews_ibfk_1` FOREIGN KEY (`service_id`) REFERENCES `expert_services` (`id`) ON DELETE CASCADE,
  CONSTRAINT `expert_reviews_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `expert_reviews`
--

LOCK TABLES `expert_reviews` WRITE;
/*!40000 ALTER TABLE `expert_reviews` DISABLE KEYS */;
/*!40000 ALTER TABLE `expert_reviews` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `expert_service_categories`
--

DROP TABLE IF EXISTS `expert_service_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `expert_service_categories` (
  `service_id` int(11) NOT NULL,
  `category_id` int(11) NOT NULL,
  PRIMARY KEY (`service_id`,`category_id`),
  KEY `idx_esc_category` (`category_id`),
  CONSTRAINT `fk_esc_category` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_esc_service` FOREIGN KEY (`service_id`) REFERENCES `expert_services` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `expert_service_categories`
--

LOCK TABLES `expert_service_categories` WRITE;
/*!40000 ALTER TABLE `expert_service_categories` DISABLE KEYS */;
INSERT INTO `expert_service_categories` VALUES
(1,1),
(3,1),
(4,1),
(5,1),
(5,5),
(5,7),
(5,13),
(5,14),
(6,2),
(6,3),
(7,14),
(8,2),
(8,3),
(8,4),
(8,5),
(8,7),
(8,14);
/*!40000 ALTER TABLE `expert_service_categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `expert_services`
--

DROP TABLE IF EXISTS `expert_services`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `expert_services` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `price` decimal(10,2) DEFAULT NULL,
  `image` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `is_consultation` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_es_id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `expert_services`
--

LOCK TABLES `expert_services` WRITE;
/*!40000 ALTER TABLE `expert_services` DISABLE KEYS */;
INSERT INTO `expert_services` VALUES
(1,3,'Resume Coaching','Expert help on resume',19.99,'/uploads/service_images/image-1754423016143-225351101.jpg','2025-08-05 19:21:28','2025-08-05 19:43:36',0),
(2,3,'Resume Coaching','Expert help on resume',49.99,'/uploads/service_images/image-1754569451107-952051340.jpg','2025-08-07 12:24:11','2025-08-07 12:24:11',0),
(3,3,'Interview Session Expert','<p class=\"ql-align-justify\">Customer service executives are the backbone of companies, who often communicate with their customers. These specialists help businesses establish and maintain strong relationships with their customers and clients. Knowing more about this domain will help you decide whether you want to pursue this career.</p><p class=\"ql-align-justify\"><br></p><h2>Who is a Customer Service Executive?</h2><p class=\"ql-align-justify\">A customer service executive is a professional who is responsible for communicating the reasons and methods related to service expectations within an organization. These professionals are assigned several duties, including answering phone calls, responding to customer questions, and resolving customer issues. They are typically responsible for front-line responsibilities that have a direct impact on a company\'s customer experience. They may also supervise a team of customer care professionals and train them on how to handle consumer complaints.</p><p class=\"ql-align-justify\">On the other hand, some customer service jobs are suitable for freshers, which range across a broad spectrum of categories, including call centers, technology, hospitality, education, and finance.</p><h2>10 Most Asked Customer Service Interview Questions</h2><ol><li>What is Customer Service?</li><li><a href=\"https://www.simplilearn.com/how-to-introduce-yourself-in-a-job-interview-article\" rel=\"noopener noreferrer\" target=\"_blank\">Tell me about yourself.</a></li><li>How do you prioritize your work?</li><li>How do you handle difficult customers?</li><li>How would previous colleagues describe you?</li><li>What are your greatest strengths?</li><li>How do you cope under pressure?</li><li>What are the top 20 customer service skills?</li><li>&nbsp;What are your career goals?</li><li>How do you keep yourself motivated?</li></ol>',29.00,'/uploads/service_images/image-1755266091630-124515018.png','2025-08-15 13:27:36','2025-08-15 13:54:51',0),
(4,3,'hh','<p>fdhdfh</p>',30.00,'/uploads/service_images/image-1755344110910-837517836.png','2025-08-16 11:35:10','2025-08-16 11:35:10',0),
(5,3,'Interview Session','<p>1 to 1 interview preparation</p>',10.00,'/uploads/service_images/image-1755441846854-913300727.jpg','2025-08-17 14:44:06','2025-08-17 14:44:06',0),
(6,3,'Web Application','<p>Web Application</p>',450.00,'/uploads/service_images/image-1755688325793-725001791.png','2025-08-20 11:12:05','2025-08-20 11:14:29',0),
(7,6,'The Newcomer Job Hunting Journey: Strategies to Get Recruiters\' Attention Faster in a New Country','<h2><strong>Why I Can Help You Navigate This Journey</strong></h2><p>I have been a newcomer. Multiple times. In multiple countries. I know the frustration of sending 100+ applications and hearing nothing. I\'ve experienced the confusion of wondering why your impressive international credentials don\'t translate into interviews. I\'ve made the expensive mistakes that cost months of opportunity—mistakes I\'m now going to help you avoid.</p><p>Through my own journey and working with hundreds of newcomers, I\'ve learned what actually works to break into the job market in a new country. This isn\'t generic career advice—this is battle-tested strategy from someone who has walked this path and helped others succeed.</p><h2><br></h2><h2><strong>What I Do (Simple + Practical)</strong></h2><p>I help you turn your international experience into a clear story that local recruiters immediately understand and value. Together we map your skills to the right job titles (NOC/TEER in Canada), build an ATS-friendly resume and LinkedIn profile that gets past automated filters, create a short, focused target-company list, and practice confident, culturally-appropriate interviews—so you can land not just any job, but the right job that advances your career.</p><p>More importantly, I show you the <strong>newcomer mistakes that keep you invisible</strong> and the <strong>specific strategies that get you shortlisted faster</strong>.</p><h2><br></h2><h2><strong>The Mistakes That Cost You Months (That I Made Too)</strong></h2><p><strong>Mistake 1: Using your home country\'s resume format and job titles</strong></p><p> Recruiters scan resumes in 6 seconds. If they don\'t recognize your job titles, see local keywords, or understand your credentials in their context, you\'re invisible—no matter how qualified you are.</p><p><br></p><p><strong>Mistake 2: Applying only through online job boards</strong></p><p> 80% of jobs are filled through the \"hidden market\"—networking and referrals. Most newcomers waste months applying cold online because they don\'t know how to network effectively in a new culture without feeling pushy or inauthentic.</p><p><br></p><p><strong>Mistake 3: Underselling yourself in interviews</strong></p><p> Many cultures value humility. North American interviews reward confident, specific storytelling about your impact. If you can\'t quickly articulate your value in the local interview style, you lose to candidates who can—even if you\'re more qualified.</p><p><strong> </strong></p><p><strong>Mistake 4: Not understanding ATS (Applicant Tracking Systems) 7 the changing nature of the labor market</strong></p><p> Your resume might never reach human eyes if it\'s not formatted correctly or doesn\'t contain the exact keywords the system is scanning for. Beautiful designs often get rejected by robots.</p><p><br></p><p><strong>Mistake 5: Targeting too broadly or applying everywhere</strong></p><p> Desperation leads to scattered applications. This exhausts you, dilutes your personal brand, and makes it impossible to network strategically. Quality and focus beat quantity every time.</p><h2><br></h2><h2><strong>3 Strong Reasons to Book Me Now</strong></h2><h3><strong>Get Seen &amp; Shortlisted Faster</strong></h3><p>I translate your background into the exact local job titles, keywords, and responsibilities that employers search for (using NOC/TEER classification systems) and build an ATS-ready resume that matches those terms precisely.</p><p><strong>Result:</strong> More callbacks in weeks, not months. Less guesswork, more strategy.</p><h3><br></h3><h3><strong>Tap the \"Hidden\" Job Market the Right Way</strong></h3><p>Most roles are filled through networking and warm introductions, but as a newcomer, you might not know where to start or feel comfortable reaching out. I give you ready-to-send messages, a simple outreach tracker, and step-by-step informational interview scripts to reach real decision-makers—without feeling salesy or pushy.</p><p><strong>Result:</strong> Access to opportunities that never get posted online. Real connections that lead to referrals.</p><h3><br></h3><h3><strong>Target the Right Organizations &amp; Interview with Local Confidence</strong></h3><p>We build clear STAR story answers that showcase your impact, practice local interview etiquette and cultural expectations, and plan strong follow-ups—so you show your value quickly and professionally in the style that local employers expect.</p><p><strong>Result:</strong> You walk into interviews feeling prepared, confident, and culturally fluent. You compete on equal footing with local candidates.</p><h2><br></h2><h2><strong>What We\'ll Work On Together</strong></h2><p>✅ <strong>Resume &amp; LinkedIn Transformation</strong></p><ul><li>Convert your international experience into local job titles and language</li><li>Build ATS-friendly formatting that gets past automated filters</li><li>Optimize keywords using NOC/TEER classification</li><li>Create compelling headlines and summaries that get attention</li></ul><p>✅ <strong>Strategic Job Targeting</strong></p><ul><li>Identify your top 10-15 target companies (not 100+)</li><li>Map your skills to realistic, achievable job titles</li><li>Research companies that value international experience</li><li>Stop wasting time on wrong-fit roles</li></ul><p>✅ <strong>Hidden Market Networking</strong></p><ul><li>Ready-to-send outreach templates for LinkedIn and email</li><li>Informational interview scripts that open doors</li><li>Networking tracker to stay organized and follow up</li><li>Cultural do\'s and don\'ts for professional networking in your new country</li></ul><p>✅ <strong>Mindset &amp; Strategy</strong></p><ul><li>Overcoming newcomer impostor syndrome</li><li>Positioning international experience as an asset, not a barrier</li><li>Managing job search stress and staying motivated</li><li>Understanding what employers really mean in job descriptions</li></ul><h2><br></h2><h2><strong>Ready to Start Right?</strong></h2><p><strong>Book your 1:1 Starter Session now</strong> and let\'s:</p><p>✔ Map your top 2–3 target job titles using NOC/TEER</p><p> ✔ Fix your resume headlines and optimize for ATS</p><p> ✔ Identify your first 10 warm networking intros this week</p><p> ✔ Create your personalized job search action plan</p><h1><br></h1><h3><strong>Stop making the mistakes that keep you invisible. Start using the strategies that get you ahead.</strong></h3>',120.00,'/uploads/service_images/image-1760094728920-254774069.jpg','2025-09-13 14:01:30','2025-10-10 11:12:08',0),
(8,3,'Your Complete Service Management App','<p>Streamline your service business with ServicePro. Manage bookings, track requests, communicate with clients, and optimize operations—all from a single, easy-to-use mobile app.Streamline your service business with ServicePro. Manage bookings, track requests, communicate with clients, and optimize operations—all from a single, easy-to-use mobile app.Streamline your service business with ServicePro. Manage bookings, track requests, communicate with clients, and optimize operations—all from a single, easy-to-use mobile app.Streamline your service business with ServicePro. Manage bookings, track requests, communicate with clients, and optimize operations—all from a single, easy-to-use mobile app.Streamline your service business with ServicePro. Manage bookings, track requests, communicate with clients, and optimize operations—all from a single, easy-to-use mobile app.Streamline your service business with ServicePro. Manage bookings, track requests, communicate with clients, and optimize operations—all from a single, easy-to-use mobile app.</p><p><br></p><p>Streamline your service business with ServicePro. Manage bookings, track requests, communicate with clients, and optimize operations—all from a single, easy-to-use mobile app.Streamline your service business with ServicePro. Manage bookings, track requests, communicate with clients, and optimize operations—all from a single, easy-to-use mobile app.Streamline your service business with ServicePro. Manage bookings, track requests, communicate with clients, and optimize operations—all from a single, easy-to-use mobile app.Streamline your service business with ServicePro. Manage bookings, track requests, communicate with clients, and optimize operations—all from a single, easy-to-use mobile app.</p><p><br></p><p><br></p><p>Streamline your service business with ServicePro. Manage bookings, track requests, communicate with clients, and optimize operations—all from a single, easy-to-use mobile app.Streamline your service business with ServicePro. Manage bookings, track requests, communicate with clients, and optimize operations—all from a single, easy-to-use mobile app.</p>',500.00,'/uploads/service_images/image-1758794881360-692739816.png','2025-09-25 10:08:01','2025-09-25 10:08:01',0);
/*!40000 ALTER TABLE `expert_services` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `expert_skills`
--

DROP TABLE IF EXISTS `expert_skills`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `expert_skills` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `expert_id` int(11) NOT NULL,
  `skill_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_skill_per_expert` (`expert_id`,`skill_id`),
  KEY `skill_id` (`skill_id`),
  CONSTRAINT `expert_skills_ibfk_1` FOREIGN KEY (`expert_id`) REFERENCES `users` (`id`),
  CONSTRAINT `expert_skills_ibfk_2` FOREIGN KEY (`skill_id`) REFERENCES `skills` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=74 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `expert_skills`
--

LOCK TABLES `expert_skills` WRITE;
/*!40000 ALTER TABLE `expert_skills` DISABLE KEYS */;
INSERT INTO `expert_skills` VALUES
(31,1,4),
(32,1,6),
(58,3,4),
(59,3,5),
(23,5,4),
(24,5,5),
(67,6,7),
(68,6,8),
(69,6,9),
(70,6,10),
(71,6,11),
(72,6,12),
(73,6,13);
/*!40000 ALTER TABLE `expert_skills` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `expert_time_slots`
--

DROP TABLE IF EXISTS `expert_time_slots`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `expert_time_slots` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `expert_id` int(11) NOT NULL,
  `start_time` datetime NOT NULL,
  `end_time` datetime NOT NULL,
  `is_booked` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_expert_slot` (`expert_id`,`start_time`),
  UNIQUE KEY `uq_expert_start_end` (`expert_id`,`start_time`,`end_time`),
  KEY `idx_expert_time` (`expert_id`,`start_time`),
  CONSTRAINT `expert_time_slots_ibfk_1` FOREIGN KEY (`expert_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=344 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `expert_time_slots`
--

LOCK TABLES `expert_time_slots` WRITE;
/*!40000 ALTER TABLE `expert_time_slots` DISABLE KEYS */;
INSERT INTO `expert_time_slots` VALUES
(1,3,'2025-08-15 10:00:00','2025-08-15 11:00:00',0,'2025-08-09 21:20:55'),
(2,3,'2025-08-11 09:00:00','2025-08-11 10:00:00',0,'2025-08-10 07:02:01'),
(3,3,'2025-08-11 10:00:00','2025-08-11 11:00:00',0,'2025-08-10 07:02:01'),
(4,3,'2025-08-11 11:00:00','2025-08-11 12:00:00',0,'2025-08-10 07:02:01'),
(5,3,'2025-08-11 12:00:00','2025-08-11 13:00:00',0,'2025-08-10 07:02:01'),
(6,3,'2025-08-18 09:00:00','2025-08-18 10:00:00',1,'2025-08-10 07:02:01'),
(7,3,'2025-08-18 10:00:00','2025-08-18 11:00:00',1,'2025-08-10 07:02:01'),
(8,3,'2025-08-18 11:00:00','2025-08-18 12:00:00',1,'2025-08-10 07:02:01'),
(9,3,'2025-08-18 12:00:00','2025-08-18 13:00:00',0,'2025-08-10 07:02:01'),
(10,3,'2025-08-25 09:00:00','2025-08-25 10:00:00',0,'2025-08-10 07:02:01'),
(11,3,'2025-08-25 10:00:00','2025-08-25 11:00:00',0,'2025-08-10 07:02:01'),
(12,3,'2025-08-25 11:00:00','2025-08-25 12:00:00',0,'2025-08-10 07:02:01'),
(13,3,'2025-08-25 12:00:00','2025-08-25 13:00:00',0,'2025-08-10 07:02:01'),
(14,3,'2025-08-11 15:00:00','2025-08-11 16:00:00',0,'2025-08-10 07:02:01'),
(15,3,'2025-08-11 16:00:00','2025-08-11 17:00:00',0,'2025-08-10 07:02:01'),
(16,3,'2025-08-11 17:00:00','2025-08-11 18:00:00',0,'2025-08-10 07:02:01'),
(17,3,'2025-08-18 15:00:00','2025-08-18 16:00:00',0,'2025-08-10 07:02:01'),
(18,3,'2025-08-18 16:00:00','2025-08-18 17:00:00',0,'2025-08-10 07:02:01'),
(19,3,'2025-08-18 17:00:00','2025-08-18 18:00:00',0,'2025-08-10 07:02:01'),
(20,3,'2025-08-25 15:00:00','2025-08-25 16:00:00',0,'2025-08-10 07:02:01'),
(21,3,'2025-08-25 16:00:00','2025-08-25 17:00:00',0,'2025-08-10 07:02:01'),
(22,3,'2025-08-25 17:00:00','2025-08-25 18:00:00',0,'2025-08-10 07:02:01'),
(23,3,'2025-08-13 10:00:00','2025-08-13 11:00:00',0,'2025-08-10 07:02:01'),
(24,3,'2025-08-13 11:00:00','2025-08-13 12:00:00',0,'2025-08-10 07:02:01'),
(25,3,'2025-08-20 10:00:00','2025-08-20 11:00:00',1,'2025-08-10 07:02:01'),
(26,3,'2025-08-20 11:00:00','2025-08-20 12:00:00',0,'2025-08-10 07:02:01'),
(27,3,'2025-08-27 10:00:00','2025-08-27 11:00:00',0,'2025-08-10 07:02:01'),
(28,3,'2025-08-27 11:00:00','2025-08-27 12:00:00',0,'2025-08-10 07:02:01'),
(29,3,'2025-08-15 09:00:00','2025-08-15 10:00:00',0,'2025-08-10 07:02:01'),
(30,3,'2025-08-15 11:00:00','2025-08-15 12:00:00',1,'2025-08-10 07:02:01'),
(31,3,'2025-08-15 12:00:00','2025-08-15 13:00:00',0,'2025-08-10 07:02:01'),
(32,3,'2025-08-15 13:00:00','2025-08-15 14:00:00',1,'2025-08-10 07:02:01'),
(33,3,'2025-08-15 14:00:00','2025-08-15 15:00:00',1,'2025-08-10 07:02:01'),
(34,3,'2025-08-15 15:00:00','2025-08-15 16:00:00',0,'2025-08-10 07:02:01'),
(35,3,'2025-08-15 16:00:00','2025-08-15 17:00:00',0,'2025-08-10 07:02:01'),
(36,3,'2025-08-22 09:00:00','2025-08-22 10:00:00',0,'2025-08-10 07:02:01'),
(37,3,'2025-08-22 10:00:00','2025-08-22 11:00:00',0,'2025-08-10 07:02:01'),
(38,3,'2025-08-22 11:00:00','2025-08-22 12:00:00',0,'2025-08-10 07:02:01'),
(39,3,'2025-08-22 12:00:00','2025-08-22 13:00:00',0,'2025-08-10 07:02:01'),
(40,3,'2025-08-22 13:00:00','2025-08-22 14:00:00',0,'2025-08-10 07:02:01'),
(41,3,'2025-08-22 14:00:00','2025-08-22 15:00:00',0,'2025-08-10 07:02:01'),
(42,3,'2025-08-22 15:00:00','2025-08-22 16:00:00',0,'2025-08-10 07:02:01'),
(43,3,'2025-08-22 16:00:00','2025-08-22 17:00:00',0,'2025-08-10 07:02:01'),
(44,3,'2025-08-29 09:00:00','2025-08-29 10:00:00',0,'2025-08-10 07:02:01'),
(45,3,'2025-08-29 10:00:00','2025-08-29 11:00:00',0,'2025-08-10 07:02:01'),
(46,3,'2025-08-29 11:00:00','2025-08-29 12:00:00',0,'2025-08-10 07:02:01'),
(47,3,'2025-08-29 12:00:00','2025-08-29 13:00:00',0,'2025-08-10 07:02:01'),
(48,3,'2025-08-29 13:00:00','2025-08-29 14:00:00',0,'2025-08-10 07:02:01'),
(49,3,'2025-08-29 14:00:00','2025-08-29 15:00:00',0,'2025-08-10 07:02:01'),
(50,3,'2025-08-29 15:00:00','2025-08-29 16:00:00',0,'2025-08-10 07:02:01'),
(51,3,'2025-08-29 16:00:00','2025-08-29 17:00:00',0,'2025-08-10 07:02:01'),
(105,3,'2025-09-01 09:00:00','2025-09-01 10:00:00',0,'2025-08-15 09:30:42'),
(106,3,'2025-09-01 10:00:00','2025-09-01 11:00:00',0,'2025-08-15 09:30:42'),
(107,3,'2025-09-01 11:00:00','2025-09-01 12:00:00',0,'2025-08-15 09:30:42'),
(108,3,'2025-09-01 12:00:00','2025-09-01 13:00:00',0,'2025-08-15 09:30:42'),
(109,3,'2025-09-08 09:00:00','2025-09-08 10:00:00',1,'2025-08-15 09:30:42'),
(110,3,'2025-09-08 10:00:00','2025-09-08 11:00:00',0,'2025-08-15 09:30:42'),
(111,3,'2025-09-08 11:00:00','2025-09-08 12:00:00',0,'2025-08-15 09:30:42'),
(112,3,'2025-09-08 12:00:00','2025-09-08 13:00:00',1,'2025-08-15 09:30:42'),
(113,3,'2025-09-15 09:00:00','2025-09-15 10:00:00',0,'2025-08-15 09:30:42'),
(114,3,'2025-09-15 10:00:00','2025-09-15 11:00:00',0,'2025-08-15 09:30:42'),
(115,3,'2025-09-15 11:00:00','2025-09-15 12:00:00',0,'2025-08-15 09:30:42'),
(116,3,'2025-09-15 12:00:00','2025-09-15 13:00:00',0,'2025-08-15 09:30:42'),
(117,3,'2025-09-22 09:00:00','2025-09-22 10:00:00',0,'2025-08-15 09:30:42'),
(118,3,'2025-09-22 10:00:00','2025-09-22 11:00:00',0,'2025-08-15 09:30:42'),
(119,3,'2025-09-22 11:00:00','2025-09-22 12:00:00',0,'2025-08-15 09:30:42'),
(120,3,'2025-09-22 12:00:00','2025-09-22 13:00:00',0,'2025-08-15 09:30:42'),
(121,3,'2025-09-29 09:00:00','2025-09-29 10:00:00',0,'2025-08-15 09:30:42'),
(122,3,'2025-09-29 10:00:00','2025-09-29 11:00:00',0,'2025-08-15 09:30:42'),
(123,3,'2025-09-29 11:00:00','2025-09-29 12:00:00',0,'2025-08-15 09:30:42'),
(124,3,'2025-09-29 12:00:00','2025-09-29 13:00:00',0,'2025-08-15 09:30:42'),
(125,3,'2025-09-01 17:00:00','2025-09-01 18:00:00',0,'2025-08-15 09:30:42'),
(126,3,'2025-09-08 17:00:00','2025-09-08 18:00:00',0,'2025-08-15 09:30:42'),
(127,3,'2025-09-15 17:00:00','2025-09-15 18:00:00',0,'2025-08-15 09:30:42'),
(128,3,'2025-09-22 17:00:00','2025-09-22 18:00:00',0,'2025-08-15 09:30:42'),
(129,3,'2025-09-29 17:00:00','2025-09-29 18:00:00',0,'2025-08-15 09:30:42'),
(130,3,'2025-09-03 10:00:00','2025-09-03 11:00:00',1,'2025-08-15 09:30:42'),
(131,3,'2025-09-03 11:00:00','2025-09-03 12:00:00',1,'2025-08-15 09:30:42'),
(132,3,'2025-09-10 10:00:00','2025-09-10 11:00:00',0,'2025-08-15 09:30:42'),
(133,3,'2025-09-10 11:00:00','2025-09-10 12:00:00',0,'2025-08-15 09:30:42'),
(134,3,'2025-09-17 10:00:00','2025-09-17 11:00:00',0,'2025-08-15 09:30:42'),
(135,3,'2025-09-17 11:00:00','2025-09-17 12:00:00',0,'2025-08-15 09:30:42'),
(136,3,'2025-09-24 10:00:00','2025-09-24 11:00:00',0,'2025-08-15 09:30:42'),
(137,3,'2025-09-24 11:00:00','2025-09-24 12:00:00',0,'2025-08-15 09:30:42'),
(138,3,'2025-09-05 09:00:00','2025-09-05 10:00:00',1,'2025-08-15 09:30:42'),
(139,3,'2025-09-05 10:00:00','2025-09-05 11:00:00',0,'2025-08-15 09:30:42'),
(140,3,'2025-09-05 11:00:00','2025-09-05 12:00:00',0,'2025-08-15 09:30:42'),
(141,3,'2025-09-05 12:00:00','2025-09-05 13:00:00',0,'2025-08-15 09:30:42'),
(142,3,'2025-09-05 13:00:00','2025-09-05 14:00:00',0,'2025-08-15 09:30:42'),
(143,3,'2025-09-05 14:00:00','2025-09-05 15:00:00',0,'2025-08-15 09:30:42'),
(144,3,'2025-09-05 15:00:00','2025-09-05 16:00:00',0,'2025-08-15 09:30:42'),
(145,3,'2025-09-05 16:00:00','2025-09-05 17:00:00',0,'2025-08-15 09:30:42'),
(146,3,'2025-09-12 09:00:00','2025-09-12 10:00:00',0,'2025-08-15 09:30:42'),
(147,3,'2025-09-12 10:00:00','2025-09-12 11:00:00',0,'2025-08-15 09:30:42'),
(148,3,'2025-09-12 11:00:00','2025-09-12 12:00:00',0,'2025-08-15 09:30:42'),
(149,3,'2025-09-12 12:00:00','2025-09-12 13:00:00',0,'2025-08-15 09:30:42'),
(150,3,'2025-09-12 13:00:00','2025-09-12 14:00:00',0,'2025-08-15 09:30:42'),
(151,3,'2025-09-12 14:00:00','2025-09-12 15:00:00',0,'2025-08-15 09:30:42'),
(152,3,'2025-09-12 15:00:00','2025-09-12 16:00:00',0,'2025-08-15 09:30:42'),
(153,3,'2025-09-12 16:00:00','2025-09-12 17:00:00',0,'2025-08-15 09:30:42'),
(154,3,'2025-09-19 09:00:00','2025-09-19 10:00:00',0,'2025-08-15 09:30:42'),
(155,3,'2025-09-19 10:00:00','2025-09-19 11:00:00',0,'2025-08-15 09:30:42'),
(156,3,'2025-09-19 11:00:00','2025-09-19 12:00:00',0,'2025-08-15 09:30:42'),
(157,3,'2025-09-19 12:00:00','2025-09-19 13:00:00',0,'2025-08-15 09:30:42'),
(158,3,'2025-09-19 13:00:00','2025-09-19 14:00:00',0,'2025-08-15 09:30:42'),
(159,3,'2025-09-19 14:00:00','2025-09-19 15:00:00',0,'2025-08-15 09:30:42'),
(160,3,'2025-09-19 15:00:00','2025-09-19 16:00:00',0,'2025-08-15 09:30:42'),
(161,3,'2025-09-19 16:00:00','2025-09-19 17:00:00',0,'2025-08-15 09:30:42'),
(162,3,'2025-09-26 09:00:00','2025-09-26 10:00:00',0,'2025-08-15 09:30:42'),
(163,3,'2025-09-26 10:00:00','2025-09-26 11:00:00',0,'2025-08-15 09:30:42'),
(164,3,'2025-09-26 11:00:00','2025-09-26 12:00:00',1,'2025-08-15 09:30:42'),
(165,3,'2025-09-26 12:00:00','2025-09-26 13:00:00',1,'2025-08-15 09:30:42'),
(166,3,'2025-09-26 13:00:00','2025-09-26 14:00:00',0,'2025-08-15 09:30:42'),
(167,3,'2025-09-26 14:00:00','2025-09-26 15:00:00',0,'2025-08-15 09:30:42'),
(168,3,'2025-09-26 15:00:00','2025-09-26 16:00:00',0,'2025-08-15 09:30:42'),
(169,3,'2025-09-26 16:00:00','2025-09-26 17:00:00',0,'2025-08-15 09:30:42'),
(170,3,'2025-08-30 03:00:00','2025-08-30 04:00:00',0,'2025-08-15 10:12:54'),
(171,1,'2025-08-24 11:00:00','2025-08-24 12:00:00',0,'2025-08-17 14:32:12'),
(172,1,'2025-08-31 11:00:00','2025-08-31 12:00:00',0,'2025-08-17 14:32:12'),
(173,1,'2025-08-18 14:00:00','2025-08-18 15:00:00',0,'2025-08-17 14:32:12'),
(174,1,'2025-08-25 14:00:00','2025-08-25 15:00:00',0,'2025-08-17 14:32:12'),
(175,1,'2025-08-17 18:00:00','2025-08-17 19:00:00',0,'2025-08-17 14:32:49'),
(176,1,'2025-08-24 18:00:00','2025-08-24 19:00:00',0,'2025-08-17 14:32:49'),
(177,1,'2025-08-31 18:00:00','2025-08-31 19:00:00',0,'2025-08-17 14:32:49'),
(182,1,'2025-09-07 11:00:00','2025-09-07 12:00:00',0,'2025-08-17 14:33:11'),
(183,1,'2025-09-14 11:00:00','2025-09-14 12:00:00',0,'2025-08-17 14:33:11'),
(184,1,'2025-09-21 11:00:00','2025-09-21 12:00:00',0,'2025-08-17 14:33:11'),
(185,1,'2025-09-28 11:00:00','2025-09-28 12:00:00',0,'2025-08-17 14:33:11'),
(186,1,'2025-09-01 14:00:00','2025-09-01 15:00:00',0,'2025-08-17 14:33:11'),
(187,1,'2025-09-08 14:00:00','2025-09-08 15:00:00',0,'2025-08-17 14:33:11'),
(188,1,'2025-09-15 14:00:00','2025-09-15 15:00:00',0,'2025-08-17 14:33:11'),
(189,1,'2025-09-22 14:00:00','2025-09-22 15:00:00',0,'2025-08-17 14:33:11'),
(190,1,'2025-09-29 14:00:00','2025-09-29 15:00:00',0,'2025-08-17 14:33:11'),
(191,1,'2025-09-07 18:00:00','2025-09-07 19:00:00',0,'2025-08-17 14:33:11'),
(192,1,'2025-09-14 18:00:00','2025-09-14 19:00:00',0,'2025-08-17 14:33:11'),
(193,1,'2025-09-21 18:00:00','2025-09-21 19:00:00',0,'2025-08-17 14:33:11'),
(194,1,'2025-09-28 18:00:00','2025-09-28 19:00:00',0,'2025-08-17 14:33:11'),
(195,6,'2025-09-14 10:00:00','2025-09-14 11:00:00',0,'2025-09-13 14:59:22'),
(196,6,'2025-09-21 10:00:00','2025-09-21 11:00:00',0,'2025-09-13 14:59:22'),
(197,6,'2025-09-28 10:00:00','2025-09-28 11:00:00',0,'2025-09-13 14:59:22'),
(198,6,'2025-09-14 14:00:00','2025-09-14 15:00:00',0,'2025-09-13 14:59:22'),
(199,6,'2025-09-21 14:00:00','2025-09-21 15:00:00',0,'2025-09-13 14:59:22'),
(200,6,'2025-09-28 14:00:00','2025-09-28 15:00:00',0,'2025-09-13 14:59:22'),
(201,6,'2025-09-14 15:00:00','2025-09-14 16:00:00',0,'2025-09-13 14:59:22'),
(202,6,'2025-09-21 15:00:00','2025-09-21 16:00:00',0,'2025-09-13 14:59:22'),
(203,6,'2025-09-28 15:00:00','2025-09-28 16:00:00',0,'2025-09-13 14:59:22'),
(204,6,'2025-09-14 16:00:00','2025-09-14 17:00:00',0,'2025-09-13 14:59:22'),
(205,6,'2025-09-21 16:00:00','2025-09-21 17:00:00',0,'2025-09-13 14:59:22'),
(206,6,'2025-09-28 16:00:00','2025-09-28 17:00:00',0,'2025-09-13 14:59:22'),
(226,3,'2025-10-06 09:00:00','2025-10-06 10:00:00',0,'2025-09-27 09:04:21'),
(227,3,'2025-10-13 09:00:00','2025-10-13 10:00:00',0,'2025-09-27 09:04:21'),
(228,3,'2025-10-20 09:00:00','2025-10-20 10:00:00',0,'2025-09-27 09:04:21'),
(229,3,'2025-10-27 09:00:00','2025-10-27 10:00:00',0,'2025-09-27 09:04:21'),
(230,3,'2025-10-06 10:00:00','2025-10-06 11:00:00',0,'2025-09-27 09:04:21'),
(231,3,'2025-10-06 11:00:00','2025-10-06 12:00:00',0,'2025-09-27 09:04:21'),
(232,3,'2025-10-06 12:00:00','2025-10-06 13:00:00',0,'2025-09-27 09:04:21'),
(233,3,'2025-10-13 10:00:00','2025-10-13 11:00:00',0,'2025-09-27 09:04:21'),
(234,3,'2025-10-13 11:00:00','2025-10-13 12:00:00',0,'2025-09-27 09:04:21'),
(235,3,'2025-10-13 12:00:00','2025-10-13 13:00:00',0,'2025-09-27 09:04:21'),
(236,3,'2025-10-20 10:00:00','2025-10-20 11:00:00',0,'2025-09-27 09:04:21'),
(237,3,'2025-10-20 11:00:00','2025-10-20 12:00:00',0,'2025-09-27 09:04:21'),
(238,3,'2025-10-20 12:00:00','2025-10-20 13:00:00',0,'2025-09-27 09:04:21'),
(239,3,'2025-10-27 10:00:00','2025-10-27 11:00:00',0,'2025-09-27 09:04:21'),
(240,3,'2025-10-27 11:00:00','2025-10-27 12:00:00',0,'2025-09-27 09:04:21'),
(241,3,'2025-10-27 12:00:00','2025-10-27 13:00:00',0,'2025-09-27 09:04:21'),
(242,3,'2025-10-06 17:00:00','2025-10-06 18:00:00',0,'2025-09-27 09:04:21'),
(243,3,'2025-10-13 17:00:00','2025-10-13 18:00:00',0,'2025-09-27 09:04:21'),
(244,3,'2025-10-20 17:00:00','2025-10-20 18:00:00',0,'2025-09-27 09:04:21'),
(245,3,'2025-10-27 17:00:00','2025-10-27 18:00:00',0,'2025-09-27 09:04:21'),
(246,3,'2025-10-01 10:00:00','2025-10-01 11:00:00',0,'2025-09-27 09:04:21'),
(247,3,'2025-10-01 11:00:00','2025-10-01 12:00:00',0,'2025-09-27 09:04:21'),
(248,3,'2025-10-08 10:00:00','2025-10-08 11:00:00',0,'2025-09-27 09:04:21'),
(249,3,'2025-10-08 11:00:00','2025-10-08 12:00:00',0,'2025-09-27 09:04:21'),
(250,3,'2025-10-15 10:00:00','2025-10-15 11:00:00',0,'2025-09-27 09:04:21'),
(251,3,'2025-10-15 11:00:00','2025-10-15 12:00:00',0,'2025-09-27 09:04:21'),
(252,3,'2025-10-22 10:00:00','2025-10-22 11:00:00',0,'2025-09-27 09:04:21'),
(253,3,'2025-10-22 11:00:00','2025-10-22 12:00:00',0,'2025-09-27 09:04:21'),
(254,3,'2025-10-29 10:00:00','2025-10-29 11:00:00',0,'2025-09-27 09:04:21'),
(255,3,'2025-10-29 11:00:00','2025-10-29 12:00:00',0,'2025-09-27 09:04:21'),
(256,3,'2025-10-03 09:00:00','2025-10-03 10:00:00',0,'2025-09-27 09:04:21'),
(257,3,'2025-10-03 10:00:00','2025-10-03 11:00:00',0,'2025-09-27 09:04:21'),
(258,3,'2025-10-03 11:00:00','2025-10-03 12:00:00',0,'2025-09-27 09:04:21'),
(259,3,'2025-10-03 12:00:00','2025-10-03 13:00:00',0,'2025-09-27 09:04:21'),
(260,3,'2025-10-03 13:00:00','2025-10-03 14:00:00',0,'2025-09-27 09:04:21'),
(261,3,'2025-10-03 14:00:00','2025-10-03 15:00:00',0,'2025-09-27 09:04:21'),
(262,3,'2025-10-03 15:00:00','2025-10-03 16:00:00',0,'2025-09-27 09:04:21'),
(263,3,'2025-10-03 16:00:00','2025-10-03 17:00:00',0,'2025-09-27 09:04:21'),
(264,3,'2025-10-10 09:00:00','2025-10-10 10:00:00',0,'2025-09-27 09:04:21'),
(265,3,'2025-10-10 10:00:00','2025-10-10 11:00:00',0,'2025-09-27 09:04:21'),
(266,3,'2025-10-10 11:00:00','2025-10-10 12:00:00',0,'2025-09-27 09:04:21'),
(267,3,'2025-10-10 12:00:00','2025-10-10 13:00:00',0,'2025-09-27 09:04:21'),
(268,3,'2025-10-10 13:00:00','2025-10-10 14:00:00',0,'2025-09-27 09:04:21'),
(269,3,'2025-10-10 14:00:00','2025-10-10 15:00:00',0,'2025-09-27 09:04:21'),
(270,3,'2025-10-10 15:00:00','2025-10-10 16:00:00',0,'2025-09-27 09:04:21'),
(271,3,'2025-10-10 16:00:00','2025-10-10 17:00:00',0,'2025-09-27 09:04:21'),
(272,3,'2025-10-17 09:00:00','2025-10-17 10:00:00',0,'2025-09-27 09:04:21'),
(273,3,'2025-10-17 10:00:00','2025-10-17 11:00:00',0,'2025-09-27 09:04:21'),
(274,3,'2025-10-17 11:00:00','2025-10-17 12:00:00',0,'2025-09-27 09:04:21'),
(275,3,'2025-10-17 12:00:00','2025-10-17 13:00:00',0,'2025-09-27 09:04:21'),
(276,3,'2025-10-17 13:00:00','2025-10-17 14:00:00',0,'2025-09-27 09:04:21'),
(277,3,'2025-10-17 14:00:00','2025-10-17 15:00:00',0,'2025-09-27 09:04:21'),
(278,3,'2025-10-17 15:00:00','2025-10-17 16:00:00',0,'2025-09-27 09:04:21'),
(279,3,'2025-10-17 16:00:00','2025-10-17 17:00:00',0,'2025-09-27 09:04:21'),
(280,3,'2025-10-24 09:00:00','2025-10-24 10:00:00',0,'2025-09-27 09:04:21'),
(281,3,'2025-10-24 10:00:00','2025-10-24 11:00:00',0,'2025-09-27 09:04:21'),
(282,3,'2025-10-24 11:00:00','2025-10-24 12:00:00',0,'2025-09-27 09:04:21'),
(283,3,'2025-10-24 12:00:00','2025-10-24 13:00:00',0,'2025-09-27 09:04:21'),
(284,3,'2025-10-24 13:00:00','2025-10-24 14:00:00',0,'2025-09-27 09:04:21'),
(285,3,'2025-10-24 14:00:00','2025-10-24 15:00:00',0,'2025-09-27 09:04:21'),
(286,3,'2025-10-24 15:00:00','2025-10-24 16:00:00',0,'2025-09-27 09:04:21'),
(287,3,'2025-10-24 16:00:00','2025-10-24 17:00:00',0,'2025-09-27 09:04:21'),
(288,3,'2025-10-31 09:00:00','2025-10-31 10:00:00',0,'2025-09-27 09:04:21'),
(289,3,'2025-10-31 10:00:00','2025-10-31 11:00:00',0,'2025-09-27 09:04:21'),
(290,3,'2025-10-31 11:00:00','2025-10-31 12:00:00',0,'2025-09-27 09:04:21'),
(291,3,'2025-10-31 12:00:00','2025-10-31 13:00:00',0,'2025-09-27 09:04:21'),
(292,3,'2025-10-31 13:00:00','2025-10-31 14:00:00',0,'2025-09-27 09:04:21'),
(293,3,'2025-10-31 14:00:00','2025-10-31 15:00:00',0,'2025-09-27 09:04:21'),
(294,3,'2025-10-31 15:00:00','2025-10-31 16:00:00',0,'2025-09-27 09:04:21'),
(295,3,'2025-10-31 16:00:00','2025-10-31 17:00:00',0,'2025-09-27 09:04:21'),
(300,6,'2025-09-28 19:00:00','2025-09-28 20:00:00',1,'2025-09-28 17:29:47'),
(301,6,'2025-09-28 20:00:00','2025-09-28 21:00:00',1,'2025-09-28 17:31:33'),
(302,6,'2025-09-28 22:00:00','2025-09-28 23:00:00',1,'2025-09-28 17:31:54'),
(303,6,'2025-10-12 10:00:00','2025-10-12 11:00:00',1,'2025-10-05 15:30:09'),
(304,6,'2025-10-19 10:00:00','2025-10-19 11:00:00',1,'2025-10-05 15:30:09'),
(305,6,'2025-10-26 10:00:00','2025-10-26 11:00:00',1,'2025-10-05 15:30:09'),
(306,6,'2025-10-12 14:00:00','2025-10-12 15:00:00',0,'2025-10-05 15:30:09'),
(307,6,'2025-10-19 14:00:00','2025-10-19 15:00:00',1,'2025-10-05 15:30:09'),
(308,6,'2025-10-26 14:00:00','2025-10-26 15:00:00',1,'2025-10-05 15:30:09'),
(309,6,'2025-10-12 15:00:00','2025-10-12 16:00:00',0,'2025-10-05 15:30:09'),
(310,6,'2025-10-19 15:00:00','2025-10-19 16:00:00',1,'2025-10-05 15:30:09'),
(311,6,'2025-10-26 15:00:00','2025-10-26 16:00:00',0,'2025-10-05 15:30:09'),
(312,6,'2025-10-05 16:00:00','2025-10-05 17:00:00',0,'2025-10-05 15:30:09'),
(313,6,'2025-10-12 16:00:00','2025-10-12 17:00:00',0,'2025-10-05 15:30:09'),
(314,6,'2025-10-19 16:00:00','2025-10-19 17:00:00',1,'2025-10-05 15:30:09'),
(315,6,'2025-10-26 16:00:00','2025-10-26 17:00:00',0,'2025-10-05 15:30:09'),
(316,6,'2025-10-18 15:00:00','2025-10-18 16:00:00',0,'2025-10-12 18:10:26'),
(317,6,'2025-10-25 15:00:00','2025-10-25 16:00:00',1,'2025-10-12 18:10:26'),
(324,6,'2025-10-14 02:00:00','2025-10-14 03:00:00',0,'2025-10-12 18:18:58'),
(325,6,'2025-10-13 18:30:00','2025-10-13 19:00:00',0,'2025-10-12 18:19:45'),
(326,6,'2025-10-12 19:00:00','2025-10-12 20:00:00',1,'2025-10-12 18:20:53'),
(335,6,'2025-10-17 01:00:00','2025-10-17 02:00:00',1,'2025-10-15 01:45:22'),
(336,6,'2025-10-23 21:00:00','2025-10-23 22:00:00',0,'2025-10-15 01:45:22'),
(337,6,'2025-10-30 21:00:00','2025-10-30 22:00:00',0,'2025-10-15 01:45:22');
/*!40000 ALTER TABLE `expert_time_slots` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `expert_weekly_availability`
--

DROP TABLE IF EXISTS `expert_weekly_availability`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `expert_weekly_availability` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `expert_id` int(11) NOT NULL,
  `day_of_week` enum('Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday') NOT NULL,
  `start_time` time NOT NULL,
  `end_time` time NOT NULL,
  `duration_minutes` int(11) NOT NULL DEFAULT 30,
  `buffer_minutes` int(11) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_expert_dow_window` (`expert_id`,`day_of_week`,`start_time`,`end_time`),
  CONSTRAINT `expert_weekly_availability_ibfk_1` FOREIGN KEY (`expert_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `expert_weekly_availability`
--

LOCK TABLES `expert_weekly_availability` WRITE;
/*!40000 ALTER TABLE `expert_weekly_availability` DISABLE KEYS */;
INSERT INTO `expert_weekly_availability` VALUES
(1,3,'Saturday','14:00:00','16:30:00',30,10,'2025-08-08 19:29:17'),
(2,3,'Saturday','10:00:00','14:00:00',30,0,'2025-08-08 20:50:48');
/*!40000 ALTER TABLE `expert_weekly_availability` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `expert_weekly_templates`
--

DROP TABLE IF EXISTS `expert_weekly_templates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `expert_weekly_templates` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `expert_id` int(11) NOT NULL,
  `day_of_week` enum('Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday') NOT NULL,
  `start_time` time NOT NULL,
  `end_time` time NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_template_hour` (`expert_id`,`day_of_week`,`start_time`,`end_time`),
  KEY `idx_expert_dow` (`expert_id`,`day_of_week`),
  CONSTRAINT `expert_weekly_templates_ibfk_1` FOREIGN KEY (`expert_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `expert_weekly_templates`
--

LOCK TABLES `expert_weekly_templates` WRITE;
/*!40000 ALTER TABLE `expert_weekly_templates` DISABLE KEYS */;
INSERT INTO `expert_weekly_templates` VALUES
(1,3,'Monday','09:00:00','13:00:00','2025-08-10 07:01:33'),
(2,3,'Monday','17:00:00','18:00:00','2025-08-10 07:01:33'),
(3,3,'Wednesday','10:00:00','12:00:00','2025-08-10 07:01:33'),
(4,3,'Friday','09:00:00','17:00:00','2025-08-10 07:01:33'),
(5,1,'Sunday','11:00:00','12:00:00','2025-08-17 14:31:17'),
(6,1,'Monday','14:00:00','15:00:00','2025-08-17 14:31:41'),
(7,1,'Sunday','18:00:00','19:00:00','2025-08-17 14:32:47'),
(9,6,'Sunday','15:00:00','16:00:00','2025-09-07 17:01:32'),
(10,6,'Sunday','16:00:00','17:00:00','2025-09-07 17:01:32'),
(12,3,'Monday','09:00:00','10:00:00','2025-09-25 10:10:29'),
(15,6,'Saturday','15:00:00','16:00:00','2025-10-12 18:10:20'),
(16,6,'Thursday','21:00:00','22:00:00','2025-10-15 01:45:14');
/*!40000 ALTER TABLE `expert_weekly_templates` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `general_profiles`
--

DROP TABLE IF EXISTS `general_profiles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `general_profiles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `full_name` varchar(100) DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `interests` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`),
  CONSTRAINT `general_profiles_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `general_profiles`
--

LOCK TABLES `general_profiles` WRITE;
/*!40000 ALTER TABLE `general_profiles` DISABLE KEYS */;
/*!40000 ALTER TABLE `general_profiles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `industries`
--

DROP TABLE IF EXISTS `industries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `industries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `industries`
--

LOCK TABLES `industries` WRITE;
/*!40000 ALTER TABLE `industries` DISABLE KEYS */;
INSERT INTO `industries` VALUES
(2,'Business'),
(1,'Updated Industry');
/*!40000 ALTER TABLE `industries` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ledger_entries`
--

DROP TABLE IF EXISTS `ledger_entries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ledger_entries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `order_id` int(11) DEFAULT NULL,
  `kind` enum('HOLD','RELEASE','PAYOUT_REQUEST','PAYOUT_REJECT','PAYOUT_PAID','ADJUSTMENT') NOT NULL,
  `amount` decimal(12,2) NOT NULL,
  `currency` char(3) NOT NULL DEFAULT 'USD',
  `description` varchar(255) DEFAULT NULL,
  `meta` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`meta`)),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_ledger_user` (`user_id`,`created_at`),
  KEY `idx_ledger_order` (`order_id`),
  CONSTRAINT `fk_ledger_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_ledger_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ledger_entries`
--

LOCK TABLES `ledger_entries` WRITE;
/*!40000 ALTER TABLE `ledger_entries` DISABLE KEYS */;
INSERT INTO `ledger_entries` VALUES
(1,3,NULL,'PAYOUT_REQUEST',37.00,'USD','Payout request created','{}','2025-09-07 20:23:22'),
(2,3,NULL,'PAYOUT_PAID',37.00,'USD','Payout paid','{}','2025-09-07 20:24:55'),
(3,3,NULL,'PAYOUT_REJECT',25.00,'USD','Payout rejected: Rejected by admin','{}','2025-09-07 21:04:05'),
(4,3,NULL,'PAYOUT_REJECT',20.00,'USD','Payout rejected: Rejected by admin','{}','2025-09-07 21:04:06'),
(5,3,NULL,'PAYOUT_PAID',25.00,'USD','Payout paid','{}','2025-09-07 21:05:03');
/*!40000 ALTER TABLE `ledger_entries` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `meeting_attendance_sessions`
--

DROP TABLE IF EXISTS `meeting_attendance_sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `meeting_attendance_sessions` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `meeting_id` int(11) DEFAULT NULL,
  `room_name` varchar(191) NOT NULL,
  `participant_sid` varchar(191) NOT NULL,
  `identity` varchar(191) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `role` varchar(50) DEFAULT NULL,
  `joined_at` datetime NOT NULL,
  `last_seen_at` datetime DEFAULT NULL,
  `left_at` datetime DEFAULT NULL,
  `duration_seconds` int(10) unsigned DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_room_sid` (`room_name`,`participant_sid`),
  KEY `idx_meeting_room` (`meeting_id`,`room_name`),
  KEY `idx_user` (`user_id`),
  KEY `idx_user_joined` (`user_id`,`joined_at`),
  KEY `idx_meeting_joined` (`meeting_id`,`joined_at`),
  KEY `idx_room_sid` (`room_name`,`participant_sid`),
  KEY `idx_att_meeting_user` (`meeting_id`,`user_id`),
  KEY `idx_att_user_joined` (`user_id`,`joined_at`),
  CONSTRAINT `fk_att_meeting` FOREIGN KEY (`meeting_id`) REFERENCES `meetings` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_att_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=94 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `meeting_attendance_sessions`
--

LOCK TABLES `meeting_attendance_sessions` WRITE;
/*!40000 ALTER TABLE `meeting_attendance_sessions` DISABLE KEYS */;
INSERT INTO `meeting_attendance_sessions` VALUES
(1,6,'room_915e28fc-6b01-4470-b983-0ea9f59d54ab','PA_icWLWoohnwML','3',3,'expert','2025-08-18 12:17:28',NULL,NULL,NULL,'2025-08-18 12:17:28','2025-08-18 12:17:28'),
(2,6,'room_915e28fc-6b01-4470-b983-0ea9f59d54ab','PA_uqL5KsGRzftE','3',3,'expert','2025-08-18 12:17:54',NULL,'2025-08-18 12:18:22',28,'2025-08-18 12:17:54','2025-08-18 12:18:22'),
(3,3,'room_2a118618-89e4-4bc9-bc0f-8aff03eda2fc','PA_YSAUAEBJhQAz','3',3,'expert','2025-08-18 12:18:39',NULL,NULL,NULL,'2025-08-18 12:18:39','2025-08-18 12:18:39'),
(4,9,'room_5e4b73d9-5c8e-40b4-8629-e799524dc106','PA_UwzDYxSiexcF','3',3,'expert','2025-08-20 13:11:44','2025-08-20 13:11:44','2025-08-20 13:11:44',0,'2025-08-20 13:11:44','2025-08-20 13:14:00'),
(5,9,'room_5e4b73d9-5c8e-40b4-8629-e799524dc106','PA_sZu4hEb3cbNw','3',3,'expert','2025-08-20 13:12:39','2025-08-20 13:12:39','2025-08-20 13:12:39',0,'2025-08-20 13:12:39','2025-08-20 13:15:00'),
(6,9,'room_5e4b73d9-5c8e-40b4-8629-e799524dc106','PA_fLjfUdyDPU9B','3',3,'expert','2025-08-20 13:21:53','2025-08-20 13:21:53','2025-08-20 13:21:53',0,'2025-08-20 13:21:53','2025-08-20 13:24:00'),
(7,22,'room_5713be9f-fc30-4b62-a29a-fd5a26b9f02a','PA_HcwQJAXMP5hs','2',2,'client','2025-09-14 14:15:35','2025-09-14 14:24:06','2025-09-14 14:24:06',511,'2025-09-14 14:15:35','2025-09-14 14:27:00'),
(8,22,'room_5713be9f-fc30-4b62-a29a-fd5a26b9f02a','PA_kAZwsKzAGCdF','6',6,'expert','2025-09-14 14:16:30','2025-09-14 14:16:30','2025-09-14 14:16:30',0,'2025-09-14 14:16:30','2025-09-14 14:19:00'),
(9,22,'room_5713be9f-fc30-4b62-a29a-fd5a26b9f02a','PA_4bLASJLPwGmG','6',6,'expert','2025-09-14 14:16:55','2025-09-14 14:16:55','2025-09-14 14:16:55',0,'2025-09-14 14:16:55','2025-09-14 14:19:00'),
(10,22,'room_5713be9f-fc30-4b62-a29a-fd5a26b9f02a','PA_HXzqDZwv5JFr','6',6,'expert','2025-09-14 14:17:14','2025-09-14 14:17:44','2025-09-14 14:17:44',30,'2025-09-14 14:17:14','2025-09-14 14:20:00'),
(11,22,'room_5713be9f-fc30-4b62-a29a-fd5a26b9f02a','PA_sKtZGqRGeLGo','6',6,'expert','2025-09-14 14:17:55','2025-09-14 14:22:55','2025-09-14 14:22:55',300,'2025-09-14 14:17:55','2025-09-14 14:25:00'),
(12,22,'room_5713be9f-fc30-4b62-a29a-fd5a26b9f02a','PA_2DK6BXY4Fako','6',6,'expert','2025-09-14 14:23:00','2025-09-14 14:24:00','2025-09-14 14:24:00',60,'2025-09-14 14:23:00','2025-09-14 14:27:00'),
(13,22,'room_5713be9f-fc30-4b62-a29a-fd5a26b9f02a','PA_um4R9QzG4Q6Y','6',6,'expert','2025-09-14 14:24:45','2025-09-14 14:26:45','2025-09-14 14:26:45',120,'2025-09-14 14:24:45','2025-09-14 14:29:00'),
(14,22,'room_5713be9f-fc30-4b62-a29a-fd5a26b9f02a','PA_ujjvBhbAViyR','6',6,'expert','2025-09-14 14:27:40','2025-09-14 14:27:40','2025-09-14 14:27:40',0,'2025-09-14 14:27:40','2025-09-14 14:30:00'),
(15,21,'room_c9ad3f77-0bc9-43a2-9a8d-610873a3c146','PA_K6ToD6joELgK','6',6,'expert','2025-09-14 20:31:27','2025-09-14 20:31:57','2025-09-14 20:31:57',30,'2025-09-14 20:31:27','2025-09-14 20:34:00'),
(16,21,'room_c9ad3f77-0bc9-43a2-9a8d-610873a3c146','PA_MDWUKZnjU2Ja','6',6,'expert','2025-09-15 03:37:42','2025-09-15 03:37:42','2025-09-15 03:37:42',0,'2025-09-15 03:37:42','2025-09-15 03:40:00'),
(17,21,'room_c9ad3f77-0bc9-43a2-9a8d-610873a3c146','PA_Rmwm9SqxpgA3','6',6,'expert','2025-09-20 19:27:17','2025-09-20 19:27:47','2025-09-20 19:27:47',30,'2025-09-20 19:27:17','2025-09-20 19:30:00'),
(18,5,'room_56dbff05-1a15-416c-9577-ad04d2851035','PA_LbKPLPYdnK78','4',4,'client','2025-09-25 10:34:00','2025-09-25 10:34:00','2025-09-25 10:34:00',0,'2025-09-25 10:34:00','2025-09-25 10:37:00'),
(19,6,'room_915e28fc-6b01-4470-b983-0ea9f59d54ab','PA_j4ZrGfz6Kr5W','4',4,'client','2025-09-25 10:38:24','2025-09-25 10:38:24','2025-09-25 10:38:24',0,'2025-09-25 10:38:24','2025-09-25 10:41:00'),
(20,20,'room_a20cc180-5e96-4c0e-84bc-3f857b94eeed','PA_Dtaka9HZHKXM','3',3,'expert','2025-09-25 10:39:11','2025-09-25 10:39:11','2025-09-25 10:39:11',0,'2025-09-25 10:39:11','2025-09-25 10:42:00'),
(21,19,'room_cdbafb4a-ace6-42f5-a2f2-d94d4a2c3930','PA_NtCBJJyKL4oE','3',3,'expert','2025-09-25 10:40:16','2025-09-25 10:40:16','2025-09-25 10:40:16',0,'2025-09-25 10:40:16','2025-09-25 10:43:00'),
(22,19,'room_cdbafb4a-ace6-42f5-a2f2-d94d4a2c3930','PA_mdXNVWunzv3f','3',3,'expert','2025-09-25 10:41:52','2025-09-25 10:41:52','2025-09-25 10:41:52',0,'2025-09-25 10:41:52','2025-09-25 10:44:00'),
(23,23,'room_d3ed6d6f-feec-4914-9453-e28a3f73c11c','PA_KqdARiTnCB3o','4',4,'client','2025-09-27 09:22:02','2025-09-27 09:22:02','2025-09-27 09:22:02',0,'2025-09-27 09:22:02','2025-09-27 09:25:00'),
(24,23,'room_d3ed6d6f-feec-4914-9453-e28a3f73c11c','PA_ZXywUayiPJRP','4',4,'client','2025-09-27 09:22:25','2025-09-27 09:22:25','2025-09-27 09:22:25',0,'2025-09-27 09:22:25','2025-09-27 09:25:00'),
(25,23,'room_d3ed6d6f-feec-4914-9453-e28a3f73c11c','PA_vkWBKr2nsgwK','4',4,'client','2025-09-27 09:26:17','2025-09-27 09:26:49','2025-09-27 09:26:49',32,'2025-09-27 09:26:17','2025-09-27 09:29:00'),
(26,23,'room_d3ed6d6f-feec-4914-9453-e28a3f73c11c','PA_D96dLznZHjMK','4',4,'client','2025-09-27 10:17:54','2025-09-27 10:28:25','2025-09-27 10:28:25',631,'2025-09-27 10:17:54','2025-09-27 10:31:00'),
(27,23,'room_d3ed6d6f-feec-4914-9453-e28a3f73c11c','PA_UAt8WW6U694F','4',4,'client','2025-09-27 10:28:53','2025-09-27 10:29:54','2025-09-27 10:29:54',61,'2025-09-27 10:28:53','2025-09-27 10:32:00'),
(28,23,'room_d3ed6d6f-feec-4914-9453-e28a3f73c11c','PA_nq873BqQd3m2','4',4,'client','2025-09-27 10:30:17','2025-09-27 10:38:48','2025-09-27 10:38:48',511,'2025-09-27 10:30:17','2025-09-27 10:41:00'),
(29,23,'room_d3ed6d6f-feec-4914-9453-e28a3f73c11c','PA_wvpzSmLzr5J8','4',4,'client','2025-09-27 10:38:51','2025-09-27 10:42:51','2025-09-27 10:42:51',240,'2025-09-27 10:38:51','2025-09-27 10:45:00'),
(30,23,'room_d3ed6d6f-feec-4914-9453-e28a3f73c11c','PA_vkDHxeu9pKVM','3',3,'expert','2025-09-27 10:40:45','2025-09-27 10:49:46','2025-09-27 10:49:46',541,'2025-09-27 10:40:45','2025-09-27 10:52:00'),
(31,23,'room_d3ed6d6f-feec-4914-9453-e28a3f73c11c','PA_3pDGfCW39h5r','4',4,'client','2025-09-27 10:43:17','2025-09-27 16:31:12','2025-09-27 15:49:12',18355,'2025-09-27 10:43:17','2025-09-27 16:31:12'),
(33,23,'room_d3ed6d6f-feec-4914-9453-e28a3f73c11c','PA_B9zg6tHJxaVY','4',4,'client','2025-09-27 10:47:12','2025-09-27 10:50:13','2025-09-27 10:50:13',181,'2025-09-27 10:47:12','2025-09-27 10:53:00'),
(34,23,'room_d3ed6d6f-feec-4914-9453-e28a3f73c11c','PA_3nyZB6rLv2bo','4',4,'client','2025-09-27 10:50:25','2025-09-27 10:57:26','2025-09-27 10:57:26',421,'2025-09-27 10:50:25','2025-09-27 11:00:00'),
(35,23,'room_d3ed6d6f-feec-4914-9453-e28a3f73c11c','PA_jj7itPjXMpms','3',3,'expert','2025-09-27 10:51:23','2025-09-27 10:59:23','2025-09-27 10:59:23',480,'2025-09-27 10:51:23','2025-09-27 11:02:00'),
(36,23,'room_d3ed6d6f-feec-4914-9453-e28a3f73c11c','PA_89usnSb3QZDK','4',4,'client','2025-09-27 10:58:18','2025-09-27 10:59:18','2025-09-27 10:59:18',60,'2025-09-27 10:58:18','2025-09-27 11:02:00'),
(37,23,'room_d3ed6d6f-feec-4914-9453-e28a3f73c11c','PA_QfpMUiRscoXt','3',3,'expert','2025-09-27 11:02:15','2025-09-27 11:03:16','2025-09-27 11:03:16',61,'2025-09-27 11:02:15','2025-09-27 11:06:00'),
(38,23,'room_d3ed6d6f-feec-4914-9453-e28a3f73c11c','PA_ohVaL5gqGrhU','4',4,'client','2025-09-27 11:02:29','2025-09-27 11:16:39','2025-09-27 11:16:39',850,'2025-09-27 11:02:29','2025-09-27 11:19:00'),
(39,23,'room_d3ed6d6f-feec-4914-9453-e28a3f73c11c','PA_abALVjGzUtbp','3',3,'expert','2025-09-27 11:03:30','2025-09-27 11:08:00','2025-09-27 11:08:00',270,'2025-09-27 11:03:30','2025-09-27 11:11:00'),
(40,23,'room_d3ed6d6f-feec-4914-9453-e28a3f73c11c','PA_FCzpKrdkh6Ez','3',3,'expert','2025-09-27 11:08:20','2025-09-27 11:15:51','2025-09-27 11:15:51',451,'2025-09-27 11:08:20','2025-09-27 11:18:00'),
(41,23,'room_d3ed6d6f-feec-4914-9453-e28a3f73c11c','PA_Ur978JScLCqZ','3',3,'expert','2025-09-27 11:16:16','2025-09-27 11:17:16','2025-09-27 11:17:16',60,'2025-09-27 11:16:16','2025-09-27 11:20:00'),
(42,23,'room_d3ed6d6f-feec-4914-9453-e28a3f73c11c','PA_7SwJFQThcbXe','4',4,'client','2025-09-27 11:16:50','2025-09-27 11:19:50','2025-09-27 11:19:50',180,'2025-09-27 11:16:50','2025-09-27 11:22:00'),
(43,23,'room_d3ed6d6f-feec-4914-9453-e28a3f73c11c','PA_ATqUsfYKrpB9','3',3,'expert','2025-09-27 11:17:38','2025-09-27 11:18:09','2025-09-27 11:18:09',31,'2025-09-27 11:17:38','2025-09-27 11:21:00'),
(44,23,'room_d3ed6d6f-feec-4914-9453-e28a3f73c11c','PA_GiszZyuNzX25','3',3,'expert','2025-09-27 11:18:16','2025-09-27 11:23:48','2025-09-27 11:23:48',332,'2025-09-27 11:18:16','2025-09-27 11:26:00'),
(45,23,'room_d3ed6d6f-feec-4914-9453-e28a3f73c11c','PA_VU99nt247yFD','3',3,'expert','2025-09-27 11:24:04','2025-09-27 11:41:34','2025-09-27 11:41:34',1050,'2025-09-27 11:24:04','2025-09-27 11:44:00'),
(46,23,'room_d3ed6d6f-feec-4914-9453-e28a3f73c11c','PA_CwKu7ZsSVVyH','3',3,'expert','2025-09-27 11:24:06','2025-09-27 11:33:07','2025-09-27 11:33:07',541,'2025-09-27 11:24:06','2025-09-27 11:36:00'),
(47,23,'room_d3ed6d6f-feec-4914-9453-e28a3f73c11c','PA_9As3Y9ScfQiM','3',3,'expert','2025-09-27 11:33:18','2025-09-27 11:41:19','2025-09-27 11:41:19',481,'2025-09-27 11:33:18','2025-09-27 11:44:00'),
(48,23,'room_d3ed6d6f-feec-4914-9453-e28a3f73c11c','PA_FHZzWtxiCrEo','4',4,'client','2025-09-27 11:43:04','2025-09-27 16:28:11','2025-09-27 15:49:46',14802,'2025-09-27 11:43:04','2025-09-27 16:28:11'),
(49,23,'room_d3ed6d6f-feec-4914-9453-e28a3f73c11c','PA_agm8Fa4pMvCk','3',3,'expert','2025-09-27 11:43:52','2025-09-27 11:44:53','2025-09-27 11:44:53',61,'2025-09-27 11:43:52','2025-09-27 11:47:00'),
(50,24,'room_d4c5526c-b07b-4178-bba0-37aa56640f11','PA_phBKMM2LVSq3','17',17,'client','2025-09-28 18:28:54','2025-09-28 18:28:54','2025-09-28 18:28:54',0,'2025-09-28 18:28:54','2025-09-28 18:31:00'),
(51,24,'room_d4c5526c-b07b-4178-bba0-37aa56640f11','PA_PSJ72rE3uqEs','17',17,'client','2025-09-28 18:29:03','2025-09-28 18:33:03','2025-09-28 18:33:03',240,'2025-09-28 18:29:03','2025-09-28 18:36:00'),
(52,25,'room_97161108-c747-4b31-97a0-39a6bb896be8','PA_ZZfeAWC8jrVC','16',16,'client','2025-09-28 18:37:59','2025-09-28 19:15:59','2025-09-28 19:15:59',2280,'2025-09-28 18:37:59','2025-09-28 19:18:00'),
(53,25,'room_97161108-c747-4b31-97a0-39a6bb896be8','PA_4mNSDwJb8JZx','6',6,'expert','2025-09-28 18:38:02','2025-09-28 18:40:32','2025-09-28 18:40:32',150,'2025-09-28 18:38:02','2025-09-28 18:43:00'),
(54,25,'room_97161108-c747-4b31-97a0-39a6bb896be8','PA_QiLMLGJtht9Y','6',6,'expert','2025-09-28 18:42:04','2025-09-28 18:42:34','2025-09-28 18:42:34',30,'2025-09-28 18:42:04','2025-09-28 18:45:00'),
(55,25,'room_97161108-c747-4b31-97a0-39a6bb896be8','PA_ViutNySjFsLu','6',6,'expert','2025-09-28 18:43:03','2025-09-28 19:16:03','2025-09-28 19:16:03',1980,'2025-09-28 18:43:03','2025-09-28 19:19:00'),
(56,26,'room_06fd2152-1aeb-448b-9c62-276096cc8a40','PA_EDAFBygEMCRo','6',6,'expert','2025-09-28 20:29:27','2025-09-28 20:31:27','2025-09-28 20:31:27',120,'2025-09-28 20:29:27','2025-09-28 20:34:00'),
(57,23,'room_d3ed6d6f-feec-4914-9453-e28a3f73c11c','PA_ZidDwPfyDSBk','3',3,'expert','2025-10-05 05:10:08','2025-10-05 05:10:39','2025-10-05 05:10:39',31,'2025-10-05 05:10:08','2025-10-05 05:13:00'),
(58,23,'room_d3ed6d6f-feec-4914-9453-e28a3f73c11c','PA_Eyc7e8HabW6g','3',3,'expert','2025-10-05 05:12:29','2025-10-05 05:12:29','2025-10-05 05:12:29',0,'2025-10-05 05:12:29','2025-10-05 05:15:00'),
(59,23,'room_d3ed6d6f-feec-4914-9453-e28a3f73c11c','PA_fGJ5tqj5NW9p','3',3,'expert','2025-10-05 05:12:41','2025-10-05 07:33:11','2025-10-05 07:33:11',8430,'2025-10-05 05:12:41','2025-10-05 07:36:00'),
(60,24,'room_d4c5526c-b07b-4178-bba0-37aa56640f11','PA_fabaFu3WAdsh','6',6,'expert','2025-10-05 15:32:38','2025-10-05 15:32:38','2025-10-05 15:32:38',0,'2025-10-05 15:32:38','2025-10-05 15:35:00'),
(61,27,'room_3a8ce434-e47c-41d6-b395-1e2e1081af28','PA_eSXhpF9pKBT3','15',15,'client','2025-10-05 16:28:51','2025-10-05 16:29:51','2025-10-05 16:29:51',60,'2025-10-05 16:28:51','2025-10-05 16:32:00'),
(62,27,'room_3a8ce434-e47c-41d6-b395-1e2e1081af28','PA_AHh5mpABxeb2','6',6,'expert','2025-10-05 16:29:36','2025-10-05 16:40:36','2025-10-05 16:40:36',660,'2025-10-05 16:29:36','2025-10-05 22:55:00'),
(63,27,'room_3a8ce434-e47c-41d6-b395-1e2e1081af28','PA_W7dP7PLTicT2','15',15,'client','2025-10-05 16:30:13','2025-10-05 16:40:43','2025-10-05 16:40:43',630,'2025-10-05 16:30:13','2025-10-05 22:55:00'),
(64,6,'room_915e28fc-6b01-4470-b983-0ea9f59d54ab','PA_mTiGwqyjqu64','3',3,'expert','2025-10-09 05:55:28','2025-10-09 07:01:59','2025-10-09 07:01:59',3991,'2025-10-09 05:55:28','2025-10-09 07:04:00'),
(65,27,'room_3a8ce434-e47c-41d6-b395-1e2e1081af28','PA_skhnCr37iuDh','15',15,'client','2025-10-09 06:57:29','2025-10-09 07:00:00','2025-10-09 07:00:00',151,'2025-10-09 06:57:29','2025-10-09 07:03:00'),
(66,27,'room_3a8ce434-e47c-41d6-b395-1e2e1081af28','PA_LPTfSzWyGXhQ','15',15,'client','2025-10-09 07:00:03','2025-10-09 07:01:34','2025-10-09 07:01:34',91,'2025-10-09 07:00:03','2025-10-09 07:04:00'),
(67,27,'room_3a8ce434-e47c-41d6-b395-1e2e1081af28','PA_Pr4n4rWkYbqy','15',15,'client','2025-10-09 07:01:50','2025-10-09 07:02:21','2025-10-09 07:02:21',31,'2025-10-09 07:01:50','2025-10-09 07:05:00'),
(68,27,'room_3a8ce434-e47c-41d6-b395-1e2e1081af28','PA_j7QV6E42P8GA','15',15,'client','2025-10-09 07:02:32','2025-10-09 07:10:33','2025-10-09 07:10:33',481,'2025-10-09 07:02:32','2025-10-09 07:13:00'),
(69,27,'room_3a8ce434-e47c-41d6-b395-1e2e1081af28','PA_8QNVb9v3EP4d','15',15,'client','2025-10-09 07:10:49','2025-10-09 07:11:19','2025-10-09 07:11:19',30,'2025-10-09 07:10:49','2025-10-09 07:14:00'),
(70,27,'room_3a8ce434-e47c-41d6-b395-1e2e1081af28','PA_oLDsPetR3yvy','15',15,'client','2025-10-09 07:11:28','2025-10-09 07:21:59','2025-10-09 07:21:59',631,'2025-10-09 07:11:28','2025-10-09 07:24:00'),
(71,27,'room_3a8ce434-e47c-41d6-b395-1e2e1081af28','PA_SGbowk8aYTfm','15',15,'client','2025-10-09 07:22:02','2025-10-09 07:22:02','2025-10-09 07:22:02',0,'2025-10-09 07:22:02','2025-10-09 07:25:00'),
(72,27,'room_3a8ce434-e47c-41d6-b395-1e2e1081af28','PA_AezwDmffDTzJ','15',15,'client','2025-10-09 07:22:36','2025-10-09 07:23:06','2025-10-09 07:23:06',30,'2025-10-09 07:22:36','2025-10-09 07:26:00'),
(73,27,'room_3a8ce434-e47c-41d6-b395-1e2e1081af28','PA_bam8etPdUMUA','15',15,'client','2025-10-09 07:23:20','2025-10-09 07:50:51','2025-10-09 07:50:51',1651,'2025-10-09 07:23:20','2025-10-09 07:53:00'),
(74,27,'room_3a8ce434-e47c-41d6-b395-1e2e1081af28','PA_snaNCqNrTM4g','15',15,'client','2025-10-09 08:51:38','2025-10-09 11:07:49','2025-10-09 11:07:49',8171,'2025-10-09 08:51:38','2025-10-09 11:10:00'),
(76,27,'room_3a8ce434-e47c-41d6-b395-1e2e1081af28','PA_pHPMfuQw8oBz','15',15,'client','2025-10-09 09:49:20','2025-10-09 10:19:51','2025-10-09 10:19:51',1831,'2025-10-09 09:49:20','2025-10-09 10:22:00'),
(77,27,'room_3a8ce434-e47c-41d6-b395-1e2e1081af28','PA_eSqACubxfHxj','15',15,'client','2025-10-09 11:07:48','2025-10-09 11:07:48','2025-10-09 11:07:48',0,'2025-10-09 11:07:48','2025-10-09 11:10:00'),
(78,27,'room_3a8ce434-e47c-41d6-b395-1e2e1081af28','PA_FXSrGTUDhNj9','15',15,'client','2025-10-09 11:08:21','2025-10-09 11:12:21','2025-10-09 11:12:21',240,'2025-10-09 11:08:21','2025-10-09 11:15:00'),
(79,27,'room_3a8ce434-e47c-41d6-b395-1e2e1081af28','PA_RbnpgRaWjmtd','15',15,'client','2025-10-09 11:12:51','2025-10-09 11:12:51','2025-10-09 11:12:51',0,'2025-10-09 11:12:51','2025-10-09 11:15:00'),
(80,27,'room_3a8ce434-e47c-41d6-b395-1e2e1081af28','PA_fQdK48hYJnpA','15',15,'client','2025-10-09 11:13:12','2025-10-09 11:16:42','2025-10-09 11:16:42',210,'2025-10-09 11:13:12','2025-10-09 11:19:00'),
(81,27,'room_3a8ce434-e47c-41d6-b395-1e2e1081af28','PA_22zs3tdmVGpV','15',15,'client','2025-10-09 11:17:04','2025-10-09 12:01:05','2025-10-09 12:01:05',2641,'2025-10-09 11:17:04','2025-10-09 12:04:00'),
(82,27,'room_3a8ce434-e47c-41d6-b395-1e2e1081af28','PA_yuWG4pFL3ajt','15',15,'client','2025-10-09 12:01:13','2025-10-09 12:01:45','2025-10-09 12:01:45',32,'2025-10-09 12:01:13','2025-10-09 12:04:00'),
(83,27,'room_3a8ce434-e47c-41d6-b395-1e2e1081af28','PA_zN9ZxYE56U4H','15',15,'client','2025-10-09 12:01:54','2025-10-09 12:02:24','2025-10-09 12:02:24',30,'2025-10-09 12:01:54','2025-10-09 12:05:00'),
(84,27,'room_3a8ce434-e47c-41d6-b395-1e2e1081af28','PA_4woNnjxgU8a8','6',6,'expert','2025-10-09 23:18:44','2025-10-09 23:18:44','2025-10-09 23:18:44',0,'2025-10-09 23:18:44','2025-10-09 23:21:00'),
(85,27,'room_3a8ce434-e47c-41d6-b395-1e2e1081af28','PA_AZaW3gzMPhjP','6',6,'expert','2025-10-10 12:16:34','2025-10-10 12:16:34','2025-10-10 12:16:34',0,'2025-10-10 12:16:34','2025-10-10 12:19:00'),
(86,27,'room_3a8ce434-e47c-41d6-b395-1e2e1081af28','PA_oh43C8qX6eXf','6',6,'expert','2025-10-10 12:17:08','2025-10-10 12:17:08','2025-10-10 12:17:08',0,'2025-10-10 12:17:08','2025-10-10 12:20:00'),
(87,27,'room_3a8ce434-e47c-41d6-b395-1e2e1081af28','PA_ftxZUkrtKVjv','6',6,'expert','2025-10-11 15:32:53','2025-10-11 15:34:23','2025-10-11 15:34:23',90,'2025-10-11 15:32:53','2025-10-11 15:37:00'),
(88,28,'room_7536ad2e-67b2-4929-bc61-7fb5ca86e0fc','PA_CexMQkZvG6af','6',6,'expert','2025-10-12 18:38:09','2025-10-12 19:05:09','2025-10-12 19:05:09',1620,'2025-10-12 18:38:09','2025-10-12 19:08:00'),
(89,28,'room_7536ad2e-67b2-4929-bc61-7fb5ca86e0fc','PA_uTsFSzByTPuf','18',18,'client','2025-10-12 18:39:45','2025-10-12 19:04:45','2025-10-12 19:04:45',1500,'2025-10-12 18:39:45','2025-10-12 19:07:00'),
(90,32,'room_7fde0de6-9d44-4853-b7eb-c6cfd40902df','PA_w5VvYUq2jMeT','18',18,'client','2025-10-17 01:09:50','2025-10-17 02:10:50','2025-10-17 02:10:50',3660,'2025-10-17 01:09:50','2025-10-17 02:13:00'),
(91,34,'room_d980e556-381b-4fda-8780-7c9d3555033c','PA_Yu5WyZxxrPRL','6',6,'expert','2025-10-17 01:10:12','2025-10-17 01:10:12','2025-10-17 01:10:12',0,'2025-10-17 01:10:12','2025-10-17 01:13:00'),
(92,34,'room_d980e556-381b-4fda-8780-7c9d3555033c','PA_eYhex4VkMT5Z','6',6,'expert','2025-10-17 01:10:43','2025-10-17 01:11:13','2025-10-17 01:11:13',30,'2025-10-17 01:10:43','2025-10-17 01:14:00'),
(93,34,'room_d980e556-381b-4fda-8780-7c9d3555033c','PA_YbEr2cbAg45h','6',6,'expert','2025-10-17 01:13:29','2025-10-17 01:13:29','2025-10-17 01:13:29',0,'2025-10-17 01:13:29','2025-10-17 01:16:00');
/*!40000 ALTER TABLE `meeting_attendance_sessions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `meeting_messages`
--

DROP TABLE IF EXISTS `meeting_messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `meeting_messages` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `meeting_id` bigint(20) unsigned NOT NULL,
  `room_name` varchar(191) NOT NULL,
  `sender_user_id` bigint(20) unsigned DEFAULT NULL,
  `sender_identity` varchar(191) NOT NULL,
  `text` text NOT NULL,
  `msg_ts` bigint(20) unsigned NOT NULL,
  `text_hash` char(64) NOT NULL,
  `raw` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`raw`)),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_meeting_chat` (`meeting_id`,`room_name`,`msg_ts`,`sender_identity`,`text_hash`),
  KEY `idx_meeting_created` (`meeting_id`,`created_at`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `meeting_messages`
--

LOCK TABLES `meeting_messages` WRITE;
/*!40000 ALTER TABLE `meeting_messages` DISABLE KEYS */;
INSERT INTO `meeting_messages` VALUES
(1,27,'room_3a8ce434-e47c-41d6-b395-1e2e1081af28',15,'unknown','hi',1759993899074,'8f434346648f6b96df89dda901c5176b10a6d83961dd3c1ac88b59b2dc327aa4',NULL,'2025-10-09 07:11:42'),
(2,27,'room_3a8ce434-e47c-41d6-b395-1e2e1081af28',15,'unknown','how are you?',1759994534748,'f0b380c58db9fc81026fadc1877e1ef163e6ee63ddad60fe4acf54f45ab37318',NULL,'2025-10-09 07:22:17'),
(3,27,'room_3a8ce434-e47c-41d6-b395-1e2e1081af28',15,'15','how are you?',1759994534747,'f0b380c58db9fc81026fadc1877e1ef163e6ee63ddad60fe4acf54f45ab37318',NULL,'2025-10-09 07:22:17'),
(5,27,'room_3a8ce434-e47c-41d6-b395-1e2e1081af28',15,'unknown','when',1759994564923,'15eaa75240aed625be3e142205df3adbbb7051802b32f450e40276be8582b6d8',NULL,'2025-10-09 07:22:47'),
(6,27,'room_3a8ce434-e47c-41d6-b395-1e2e1081af28',15,'15','when',1759994564922,'15eaa75240aed625be3e142205df3adbbb7051802b32f450e40276be8582b6d8',NULL,'2025-10-09 07:22:47'),
(7,27,'room_3a8ce434-e47c-41d6-b395-1e2e1081af28',15,'15','how are you?',1760008092381,'f0b380c58db9fc81026fadc1877e1ef163e6ee63ddad60fe4acf54f45ab37318',NULL,'2025-10-09 11:08:13'),
(8,27,'room_3a8ce434-e47c-41d6-b395-1e2e1081af28',15,'15','how are you?',1760008092375,'f0b380c58db9fc81026fadc1877e1ef163e6ee63ddad60fe4acf54f45ab37318',NULL,'2025-10-09 11:08:13'),
(9,27,'room_3a8ce434-e47c-41d6-b395-1e2e1081af28',15,'15','koi tumi?',1760008383035,'16c5e9382e9ada712a28d0e082c33750546669c14f005542c5e660708446d90b',NULL,'2025-10-09 11:13:03'),
(10,28,'room_7536ad2e-67b2-4929-bc61-7fb5ca86e0fc',6,'6','norman@prosfata.com',1760294624027,'d4eeb6678a0fafb09fce7375493680013be0a3f33599b324339490b258cf8e50',NULL,'2025-10-12 18:43:43'),
(11,28,'room_7536ad2e-67b2-4929-bc61-7fb5ca86e0fc',6,'6','https://blitzy.com/',1760295030969,'011225f6771faade431aed842edb68abd58643aa7c6510519c8fe215bee6f0e7',NULL,'2025-10-12 18:50:30');
/*!40000 ALTER TABLE `meeting_messages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `meeting_participants`
--

DROP TABLE IF EXISTS `meeting_participants`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `meeting_participants` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `meeting_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `role` enum('host','participant') DEFAULT 'participant',
  `status` enum('invited','accepted','declined','left') DEFAULT 'accepted',
  `reminder_sent` tinyint(1) DEFAULT 0,
  `joined_at` datetime DEFAULT NULL,
  `left_at` datetime DEFAULT NULL,
  `invited_by` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_meeting_user` (`meeting_id`,`user_id`),
  UNIQUE KEY `uniq_meeting_user` (`meeting_id`,`user_id`),
  KEY `idx_mp_meeting` (`meeting_id`),
  KEY `idx_mp_user` (`user_id`),
  KEY `idx_meeting` (`meeting_id`),
  CONSTRAINT `meeting_participants_ibfk_1` FOREIGN KEY (`meeting_id`) REFERENCES `meetings` (`id`) ON DELETE CASCADE,
  CONSTRAINT `meeting_participants_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `meeting_participants`
--

LOCK TABLES `meeting_participants` WRITE;
/*!40000 ALTER TABLE `meeting_participants` DISABLE KEYS */;
INSERT INTO `meeting_participants` VALUES
(1,6,3,'host','accepted',0,NULL,NULL,NULL,'2025-08-15 17:50:00'),
(2,6,4,'participant','accepted',0,NULL,NULL,NULL,'2025-08-15 17:50:00'),
(3,7,3,'host','accepted',0,NULL,NULL,NULL,'2025-08-16 06:52:01'),
(4,7,4,'participant','accepted',0,NULL,NULL,NULL,'2025-08-16 06:52:01'),
(7,9,3,'host','accepted',0,NULL,NULL,NULL,'2025-08-19 14:29:59'),
(8,9,5,'participant','accepted',0,NULL,NULL,NULL,'2025-08-19 14:29:59'),
(9,10,3,'host','accepted',0,NULL,NULL,NULL,'2025-09-01 20:44:43'),
(10,10,2,'participant','accepted',0,NULL,NULL,NULL,'2025-09-01 20:44:43'),
(11,17,3,'host','accepted',0,NULL,NULL,NULL,'2025-09-07 10:47:18'),
(12,17,2,'participant','accepted',0,NULL,NULL,NULL,'2025-09-07 10:47:18'),
(13,18,2,'','accepted',0,NULL,NULL,NULL,'2025-09-07 12:24:13'),
(14,18,3,'','accepted',0,NULL,NULL,NULL,'2025-09-07 12:24:13'),
(15,24,6,'host','accepted',0,NULL,NULL,NULL,'2025-09-28 18:28:22'),
(16,24,17,'participant','accepted',0,NULL,NULL,NULL,'2025-09-28 18:28:22'),
(17,25,6,'host','accepted',0,NULL,NULL,NULL,'2025-09-28 18:37:40'),
(18,25,16,'participant','accepted',0,NULL,NULL,NULL,'2025-09-28 18:37:40'),
(19,27,6,'host','accepted',0,NULL,NULL,NULL,'2025-10-05 16:28:28'),
(20,27,15,'participant','accepted',0,NULL,NULL,NULL,'2025-10-05 16:28:28');
/*!40000 ALTER TABLE `meeting_participants` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `meeting_reminders`
--

DROP TABLE IF EXISTS `meeting_reminders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `meeting_reminders` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `meeting_id` bigint(20) unsigned NOT NULL,
  `user_id` bigint(20) unsigned NOT NULL,
  `kind` varchar(32) NOT NULL,
  `status` varchar(16) NOT NULL,
  `sent_at` datetime NOT NULL DEFAULT current_timestamp(),
  `error_text` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_mr_meeting_kind` (`meeting_id`,`kind`),
  KEY `idx_mr_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `meeting_reminders`
--

LOCK TABLES `meeting_reminders` WRITE;
/*!40000 ALTER TABLE `meeting_reminders` DISABLE KEYS */;
/*!40000 ALTER TABLE `meeting_reminders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `meetings`
--

DROP TABLE IF EXISTS `meetings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `meetings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `order_id` int(11) NOT NULL,
  `expert_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `slot_id` int(11) NOT NULL,
  `start_time` datetime NOT NULL,
  `end_time` datetime NOT NULL,
  `created_by` int(11) DEFAULT NULL,
  `provider` enum('livekit','zoom','meet') DEFAULT 'livekit',
  `room_name` varchar(128) NOT NULL,
  `join_url_user` varchar(255) DEFAULT NULL,
  `join_url_expert` varchar(255) DEFAULT NULL,
  `status` enum('upcoming','ongoing','completed','cancelled','expired') NOT NULL DEFAULT 'upcoming',
  `started_at` datetime DEFAULT NULL,
  `ended_at` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `meeting_type` enum('one-on-one','group') NOT NULL DEFAULT 'one-on-one',
  `video_tool` enum('jitsi','webrtc','livekit') NOT NULL DEFAULT 'livekit',
  `meet_type` enum('audio','video') NOT NULL DEFAULT 'video',
  `timezone` varchar(100) NOT NULL DEFAULT 'UTC',
  `live_room_name` varchar(255) DEFAULT NULL,
  `is_live` tinyint(1) NOT NULL DEFAULT 0,
  `reminder_sent` tinyint(1) NOT NULL DEFAULT 0,
  `reminder_30_sent` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_order_start` (`order_id`,`start_time`),
  KEY `slot_id` (`slot_id`),
  KEY `idx_meeting_expert_time` (`expert_id`,`start_time`),
  KEY `idx_meetings_created_by` (`created_by`),
  KEY `idx_meeting_start` (`start_time`),
  KEY `idx_meetings_times` (`start_time`,`end_time`,`status`),
  KEY `idx_meetings_status_start` (`status`,`start_time`),
  KEY `idx_meetings_order_id` (`order_id`),
  CONSTRAINT `fk_meetings_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `meetings_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `service_orders` (`id`) ON DELETE CASCADE,
  CONSTRAINT `meetings_ibfk_2` FOREIGN KEY (`slot_id`) REFERENCES `expert_time_slots` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=37 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `meetings`
--

LOCK TABLES `meetings` WRITE;
/*!40000 ALTER TABLE `meetings` DISABLE KEYS */;
INSERT INTO `meetings` VALUES
(3,1,3,3,6,'2025-08-18 09:00:00','2025-08-18 10:00:00',NULL,'livekit','room_2a118618-89e4-4bc9-bc0f-8aff03eda2fc','/meet/join/room_2a118618-89e4-4bc9-bc0f-8aff03eda2fc?as=user','/meet/join/room_2a118618-89e4-4bc9-bc0f-8aff03eda2fc?as=expert','completed',NULL,NULL,'2025-08-10 07:47:52','one-on-one','livekit','video','UTC',NULL,0,0,0),
(4,3,3,3,7,'2025-08-18 10:00:00','2025-08-18 11:00:00',NULL,'livekit','room_6b304630-692a-49a5-8cec-e5d96e9835f5','/meet/join/room_6b304630-692a-49a5-8cec-e5d96e9835f5?as=user','/meet/join/room_6b304630-692a-49a5-8cec-e5d96e9835f5?as=expert','expired',NULL,NULL,'2025-08-10 07:50:26','one-on-one','livekit','video','UTC',NULL,0,0,0),
(5,5,3,4,8,'2025-08-18 11:00:00','2025-08-18 12:00:00',NULL,'livekit','room_56dbff05-1a15-416c-9577-ad04d2851035','/meet/join/room_56dbff05-1a15-416c-9577-ad04d2851035?as=user','/meet/join/room_56dbff05-1a15-416c-9577-ad04d2851035?as=expert','',NULL,NULL,'2025-08-11 19:21:19','one-on-one','livekit','video','UTC',NULL,0,0,0),
(6,6,3,4,30,'2025-08-15 11:00:00','2025-08-15 12:00:00',NULL,'livekit','room_915e28fc-6b01-4470-b983-0ea9f59d54ab','/meet/join/room_915e28fc-6b01-4470-b983-0ea9f59d54ab?as=user','/meet/join/room_915e28fc-6b01-4470-b983-0ea9f59d54ab?as=expert','completed',NULL,NULL,'2025-08-14 19:44:30','one-on-one','livekit','video','UTC',NULL,0,0,0),
(7,36,3,4,32,'2025-08-15 13:00:00','2025-08-15 14:00:00',NULL,'livekit','room_79c13df8-f57a-44ed-96d3-fe860a2e0e55','/meet/join/room_79c13df8-f57a-44ed-96d3-fe860a2e0e55?as=user','/meet/join/room_79c13df8-f57a-44ed-96d3-fe860a2e0e55?as=expert','',NULL,NULL,'2025-08-16 06:52:01','one-on-one','livekit','video','UTC',NULL,0,0,0),
(8,39,3,3,33,'2025-08-15 14:00:00','2025-08-15 15:00:00',NULL,'livekit','room_bfe280da-3afd-4c47-9df4-a5c9fa7eb8db','/meet/join/room_bfe280da-3afd-4c47-9df4-a5c9fa7eb8db?as=user','/meet/join/room_bfe280da-3afd-4c47-9df4-a5c9fa7eb8db?as=expert','',NULL,NULL,'2025-08-16 07:40:16','one-on-one','livekit','video','UTC',NULL,0,0,0),
(9,41,3,5,25,'2025-08-20 10:00:00','2025-08-20 11:00:00',NULL,'livekit','room_5e4b73d9-5c8e-40b4-8629-e799524dc106','/meet/join/room_5e4b73d9-5c8e-40b4-8629-e799524dc106?as=user','/meet/join/room_5e4b73d9-5c8e-40b4-8629-e799524dc106?as=expert','completed',NULL,NULL,'2025-08-19 14:29:59','one-on-one','livekit','video','UTC',NULL,0,0,0),
(10,50,3,2,130,'2025-09-03 10:00:00','2025-09-03 11:00:00',NULL,'livekit','room_4148e394-59a2-499c-9e9b-894dd0127564','/meet/join/room_4148e394-59a2-499c-9e9b-894dd0127564?as=user','/meet/join/room_4148e394-59a2-499c-9e9b-894dd0127564?as=expert','completed',NULL,NULL,'2025-09-01 20:44:43','one-on-one','livekit','video','UTC',NULL,0,0,0),
(11,13,3,2,138,'2025-09-05 09:00:00','2025-09-05 10:00:00',NULL,'livekit','room_c1ca031b-3fb5-426f-8bf0-8688dca16dc3','/meet/join/room_c1ca031b-3fb5-426f-8bf0-8688dca16dc3?as=user','/meet/join/room_c1ca031b-3fb5-426f-8bf0-8688dca16dc3?as=expert','completed',NULL,NULL,'2025-09-02 14:59:54','one-on-one','livekit','video','UTC',NULL,0,0,0),
(12,9,3,2,109,'2025-09-08 09:00:00','2025-09-08 10:00:00',NULL,'livekit','room_fcd6a159-c228-4fb8-812c-ae7865e8ef91','/meet/join/room_fcd6a159-c228-4fb8-812c-ae7865e8ef91?as=user','/meet/join/room_fcd6a159-c228-4fb8-812c-ae7865e8ef91?as=expert','completed',NULL,NULL,'2025-09-06 17:46:18','one-on-one','livekit','video','UTC',NULL,0,0,0),
(13,15,3,2,110,'2025-09-08 10:00:00','2025-09-08 11:00:00',NULL,'livekit','room_aea058dc-a77c-4af4-b568-4cccce150d7d','/meet/join/room_aea058dc-a77c-4af4-b568-4cccce150d7d?as=user','/meet/join/room_aea058dc-a77c-4af4-b568-4cccce150d7d?as=expert','completed',NULL,NULL,'2025-09-07 09:13:15','one-on-one','livekit','video','UTC',NULL,0,0,0),
(16,15,3,2,111,'2025-09-08 11:00:00','2025-09-08 12:00:00',NULL,'livekit','room_6ab22115-e257-4141-af89-0c36b3c90d95','/meet/join/room_6ab22115-e257-4141-af89-0c36b3c90d95?as=user','/meet/join/room_6ab22115-e257-4141-af89-0c36b3c90d95?as=expert','completed',NULL,NULL,'2025-09-07 09:36:13','one-on-one','livekit','video','UTC',NULL,0,0,0),
(17,53,3,2,112,'2025-09-08 12:00:00','2025-09-08 13:00:00',NULL,'livekit','room_562d638d-1830-4e33-89c0-c6f9f95f7f42','/meet/join/room_562d638d-1830-4e33-89c0-c6f9f95f7f42?as=user','/meet/join/room_562d638d-1830-4e33-89c0-c6f9f95f7f42?as=expert','completed',NULL,NULL,'2025-09-07 10:47:18','one-on-one','livekit','video','UTC',NULL,0,0,0),
(18,55,3,2,132,'2025-09-10 10:00:00','2025-09-10 11:00:00',NULL,'livekit','room_a1ef1f78-1243-4e28-aed8-c69e3bd26c11','/meet/join/room_a1ef1f78-1243-4e28-aed8-c69e3bd26c11/55?as=user','/meet/join/room_a1ef1f78-1243-4e28-aed8-c69e3bd26c11/55?as=expert','completed',NULL,NULL,'2025-09-07 12:24:13','one-on-one','livekit','video','UTC',NULL,0,0,0),
(19,56,3,2,133,'2025-09-10 11:00:00','2025-09-10 12:00:00',NULL,'livekit','room_cdbafb4a-ace6-42f5-a2f2-d94d4a2c3930','/meet/join/room_cdbafb4a-ace6-42f5-a2f2-d94d4a2c3930/56?as=user','/meet/join/room_cdbafb4a-ace6-42f5-a2f2-d94d4a2c3930/56?as=expert','completed',NULL,NULL,'2025-09-07 13:50:09','one-on-one','livekit','video','UTC',NULL,0,0,0),
(20,58,3,13,114,'2025-09-15 10:00:00','2025-09-15 11:00:00',NULL,'livekit','room_a20cc180-5e96-4c0e-84bc-3f857b94eeed','/meet/join/room_a20cc180-5e96-4c0e-84bc-3f857b94eeed/58?as=user','/meet/join/room_a20cc180-5e96-4c0e-84bc-3f857b94eeed/58?as=expert','completed',NULL,NULL,'2025-09-13 08:03:53','one-on-one','livekit','video','UTC',NULL,0,0,0),
(21,59,6,2,199,'2025-09-21 14:00:00','2025-09-21 15:00:00',NULL,'livekit','room_c9ad3f77-0bc9-43a2-9a8d-610873a3c146','/meet/join/room_c9ad3f77-0bc9-43a2-9a8d-610873a3c146/59?as=user','/meet/join/room_c9ad3f77-0bc9-43a2-9a8d-610873a3c146/59?as=expert','completed',NULL,NULL,'2025-09-14 07:25:22','one-on-one','livekit','video','UTC',NULL,0,0,0),
(22,60,6,2,198,'2025-09-14 14:00:00','2025-09-14 15:00:00',NULL,'livekit','room_5713be9f-fc30-4b62-a29a-fd5a26b9f02a','/meet/join/room_5713be9f-fc30-4b62-a29a-fd5a26b9f02a/60?as=user','/meet/join/room_5713be9f-fc30-4b62-a29a-fd5a26b9f02a/60?as=expert','completed',NULL,NULL,'2025-09-14 07:38:06','one-on-one','livekit','video','UTC',NULL,0,0,0),
(23,63,3,4,121,'2025-09-29 09:00:00','2025-09-29 10:00:00',NULL,'livekit','room_d3ed6d6f-feec-4914-9453-e28a3f73c11c','/meet/join/room_d3ed6d6f-feec-4914-9453-e28a3f73c11c/63?as=user','/meet/join/room_d3ed6d6f-feec-4914-9453-e28a3f73c11c/63?as=expert','completed',NULL,NULL,'2025-09-27 09:21:29','one-on-one','livekit','video','UTC',NULL,0,0,0),
(24,67,6,17,300,'2025-09-28 19:00:00','2025-09-28 20:00:00',NULL,'livekit','room_d4c5526c-b07b-4178-bba0-37aa56640f11','/meet/join/room_d4c5526c-b07b-4178-bba0-37aa56640f11?as=user','/meet/join/room_d4c5526c-b07b-4178-bba0-37aa56640f11?as=expert','completed',NULL,NULL,'2025-09-28 18:28:22','one-on-one','livekit','video','UTC',NULL,0,0,0),
(25,68,6,16,301,'2025-09-28 20:00:00','2025-09-28 21:00:00',NULL,'livekit','room_97161108-c747-4b31-97a0-39a6bb896be8','/meet/join/room_97161108-c747-4b31-97a0-39a6bb896be8?as=user','/meet/join/room_97161108-c747-4b31-97a0-39a6bb896be8?as=expert','completed',NULL,NULL,'2025-09-28 18:37:40','one-on-one','livekit','video','UTC',NULL,0,0,0),
(26,31,6,17,302,'2025-09-28 22:00:00','2025-09-28 23:00:00',NULL,'livekit','room_06fd2152-1aeb-448b-9c62-276096cc8a40','/meet/join/room_06fd2152-1aeb-448b-9c62-276096cc8a40?as=user','/meet/join/room_06fd2152-1aeb-448b-9c62-276096cc8a40?as=expert','completed',NULL,NULL,'2025-09-28 20:24:25','one-on-one','livekit','video','UTC',NULL,0,0,0),
(27,70,6,15,303,'2025-10-12 10:00:00','2025-10-12 11:00:00',NULL,'livekit','room_3a8ce434-e47c-41d6-b395-1e2e1081af28','/meet/join/room_3a8ce434-e47c-41d6-b395-1e2e1081af28?as=user','/meet/join/room_3a8ce434-e47c-41d6-b395-1e2e1081af28?as=expert','completed',NULL,NULL,'2025-10-05 16:28:28','one-on-one','livekit','video','UTC',NULL,0,0,0),
(28,35,6,18,326,'2025-10-12 19:00:00','2025-10-12 20:00:00',NULL,'livekit','room_7536ad2e-67b2-4929-bc61-7fb5ca86e0fc','/meet/join/room_7536ad2e-67b2-4929-bc61-7fb5ca86e0fc?as=user','/meet/join/room_7536ad2e-67b2-4929-bc61-7fb5ca86e0fc?as=expert','completed',NULL,NULL,'2025-10-12 18:33:01','one-on-one','livekit','video','UTC',NULL,0,0,0),
(29,36,6,17,325,'2025-10-13 18:30:00','2025-10-13 19:00:00',NULL,'livekit','room_57a146c7-e421-4ab5-916c-c7918132c9c0','/meet/join/room_57a146c7-e421-4ab5-916c-c7918132c9c0?as=user','/meet/join/room_57a146c7-e421-4ab5-916c-c7918132c9c0?as=expert','completed',NULL,NULL,'2025-10-12 18:33:33','one-on-one','livekit','video','UTC',NULL,0,0,0),
(30,36,6,17,316,'2025-10-18 15:00:00','2025-10-18 16:00:00',NULL,'livekit','room_587386c1-6778-41c1-a380-7c304da53c95','/meet/join/room_587386c1-6778-41c1-a380-7c304da53c95?as=user','/meet/join/room_587386c1-6778-41c1-a380-7c304da53c95?as=expert','upcoming',NULL,NULL,'2025-10-12 18:33:42','one-on-one','livekit','video','UTC',NULL,0,0,0),
(31,36,6,17,315,'2025-10-26 16:00:00','2025-10-26 17:00:00',NULL,'livekit','room_01d1cf60-1541-42fa-8b7f-3d4dd6374e50','/meet/join/room_01d1cf60-1541-42fa-8b7f-3d4dd6374e50?as=user','/meet/join/room_01d1cf60-1541-42fa-8b7f-3d4dd6374e50?as=expert','upcoming',NULL,NULL,'2025-10-12 18:33:49','one-on-one','livekit','video','UTC',NULL,0,0,0),
(32,35,6,18,304,'2025-10-19 10:00:00','2025-10-19 11:00:00',NULL,'livekit','room_7fde0de6-9d44-4853-b7eb-c6cfd40902df','/meet/join/room_7fde0de6-9d44-4853-b7eb-c6cfd40902df?as=user','/meet/join/room_7fde0de6-9d44-4853-b7eb-c6cfd40902df?as=expert','upcoming',NULL,NULL,'2025-10-12 18:34:06','one-on-one','livekit','video','UTC',NULL,0,0,0),
(33,35,6,18,308,'2025-10-26 14:00:00','2025-10-26 15:00:00',NULL,'livekit','room_3189f480-21db-49f8-8766-b8bccb55d1a0','/meet/join/room_3189f480-21db-49f8-8766-b8bccb55d1a0?as=user','/meet/join/room_3189f480-21db-49f8-8766-b8bccb55d1a0?as=expert','upcoming',NULL,NULL,'2025-10-12 18:34:10','one-on-one','livekit','video','UTC',NULL,0,0,0),
(34,40,6,18,335,'2025-10-17 01:00:00','2025-10-17 02:00:00',NULL,'livekit','room_d980e556-381b-4fda-8780-7c9d3555033c','/meet/join/room_d980e556-381b-4fda-8780-7c9d3555033c?as=user','/meet/join/room_d980e556-381b-4fda-8780-7c9d3555033c?as=expert','completed',NULL,NULL,'2025-10-16 22:58:34','one-on-one','livekit','video','UTC',NULL,0,0,0),
(35,40,6,18,310,'2025-10-19 15:00:00','2025-10-19 16:00:00',NULL,'livekit','room_bb9b5e79-53c4-4a02-bdcb-b1d8d66eb64d','/meet/join/room_bb9b5e79-53c4-4a02-bdcb-b1d8d66eb64d?as=user','/meet/join/room_bb9b5e79-53c4-4a02-bdcb-b1d8d66eb64d?as=expert','upcoming',NULL,NULL,'2025-10-16 22:58:40','one-on-one','livekit','video','UTC',NULL,0,0,0),
(36,40,6,18,307,'2025-10-19 14:00:00','2025-10-19 15:00:00',NULL,'livekit','room_544430e5-14c7-42fb-a9f4-39cb5ea3ec51','/meet/join/room_544430e5-14c7-42fb-a9f4-39cb5ea3ec51?as=user','/meet/join/room_544430e5-14c7-42fb-a9f4-39cb5ea3ec51?as=expert','upcoming',NULL,NULL,'2025-10-16 22:58:43','one-on-one','livekit','video','UTC',NULL,0,0,0);
/*!40000 ALTER TABLE `meetings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `message_reads`
--

DROP TABLE IF EXISTS `message_reads`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `message_reads` (
  `message_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `read_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`message_id`,`user_id`),
  KEY `fk_mread_user` (`user_id`),
  CONSTRAINT `fk_mread_message` FOREIGN KEY (`message_id`) REFERENCES `messages` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_mread_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `message_reads`
--

LOCK TABLES `message_reads` WRITE;
/*!40000 ALTER TABLE `message_reads` DISABLE KEYS */;
INSERT INTO `message_reads` VALUES
(1,2,'2025-09-25 10:19:57'),
(1,4,'2025-09-25 10:31:06'),
(2,2,'2025-09-25 10:19:57'),
(2,4,'2025-09-25 10:31:06'),
(3,2,'2025-09-25 10:19:57'),
(3,4,'2025-09-25 10:31:06'),
(4,2,'2025-09-25 10:19:57'),
(4,4,'2025-09-25 10:31:06'),
(5,3,'2025-08-17 19:13:16'),
(5,4,'2025-08-17 19:13:42'),
(6,2,'2025-09-25 10:19:57'),
(6,4,'2025-09-25 10:31:06'),
(7,2,'2025-09-25 10:19:57'),
(7,4,'2025-09-25 10:31:06'),
(8,2,'2025-09-25 10:19:57'),
(8,4,'2025-09-25 10:31:06'),
(9,3,'2025-08-17 19:14:05'),
(9,4,'2025-08-17 19:13:42'),
(10,3,'2025-08-17 19:14:05'),
(10,4,'2025-08-17 21:13:03'),
(11,3,'2025-08-20 06:16:51'),
(11,4,'2025-08-17 21:13:03'),
(12,3,'2025-08-20 06:16:51'),
(12,4,'2025-08-17 22:21:48'),
(13,1,'2025-08-18 00:34:50'),
(13,3,'2025-08-18 00:34:43'),
(14,1,'2025-08-18 00:34:50'),
(14,3,'2025-08-18 00:42:42'),
(15,1,'2025-08-18 00:42:16'),
(15,3,'2025-08-18 00:42:42'),
(16,1,'2025-08-18 00:42:23'),
(16,3,'2025-08-18 00:42:42'),
(17,1,'2025-08-18 00:42:54'),
(17,3,'2025-08-18 00:42:42'),
(18,1,'2025-08-18 00:42:54'),
(19,3,'2025-08-20 06:16:51'),
(19,4,'2025-08-20 06:16:45'),
(20,1,'2025-08-18 00:51:38'),
(21,1,'2025-08-18 01:00:39'),
(22,1,'2025-08-18 01:05:26'),
(23,1,'2025-08-20 10:11:27'),
(24,3,'2025-08-20 06:16:51'),
(24,4,'2025-08-20 06:16:45'),
(25,3,'2025-08-20 06:16:51'),
(25,4,'2025-08-20 06:16:45'),
(26,3,'2025-08-20 06:16:51'),
(26,4,'2025-08-20 13:24:13'),
(27,3,'2025-08-20 13:24:23'),
(27,4,'2025-08-20 13:24:13'),
(28,2,'2025-09-25 10:19:57'),
(28,4,'2025-09-25 10:31:06'),
(29,3,'2025-08-20 13:24:23'),
(29,4,'2025-08-20 13:24:13'),
(30,3,'2025-08-20 13:24:23'),
(30,4,'2025-08-20 13:24:13'),
(31,3,'2025-08-20 13:24:23'),
(31,4,'2025-08-20 13:24:13'),
(35,3,'2025-08-20 13:24:23'),
(35,4,'2025-08-20 13:24:56'),
(36,3,'2025-09-14 11:57:22'),
(36,4,'2025-08-20 13:24:56'),
(37,3,'2025-09-14 11:57:22'),
(37,4,'2025-08-20 13:29:14'),
(38,3,'2025-09-14 11:57:27'),
(39,3,'2025-09-14 11:57:27'),
(40,3,'2025-09-14 11:57:27'),
(43,3,'2025-09-14 11:57:25'),
(44,3,'2025-09-14 11:57:22'),
(44,4,'2025-10-11 12:44:40'),
(48,3,'2025-09-20 04:45:30'),
(48,6,'2025-09-25 11:39:14'),
(49,6,'2025-09-25 11:39:14'),
(50,6,'2025-09-25 11:39:14'),
(51,2,'2025-09-28 07:09:34'),
(51,4,'2025-09-25 10:31:06'),
(52,2,'2025-09-28 07:09:34'),
(52,4,'2025-09-25 10:31:06'),
(53,2,'2025-09-28 07:09:36'),
(53,3,'2025-09-25 10:46:37'),
(54,2,'2025-09-28 07:09:36'),
(54,3,'2025-10-05 05:09:24'),
(55,6,'2025-09-25 11:39:14'),
(56,2,'2025-09-28 07:09:34'),
(57,3,'2025-10-05 05:09:29'),
(57,4,'2025-10-11 12:44:40'),
(58,3,'2025-10-05 05:09:24'),
(60,4,'2025-10-11 12:44:40'),
(61,6,'2025-10-13 18:07:50'),
(62,4,'2025-10-11 12:44:40'),
(63,4,'2025-10-11 12:44:40');
/*!40000 ALTER TABLE `message_reads` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `messages`
--

DROP TABLE IF EXISTS `messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `messages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `chat_id` int(11) NOT NULL,
  `sender_id` int(11) NOT NULL,
  `content` text DEFAULT NULL,
  `attachment` varchar(255) DEFAULT NULL,
  `file_url` text DEFAULT NULL,
  `is_read` tinyint(1) NOT NULL DEFAULT 0,
  `is_deleted` tinyint(1) NOT NULL DEFAULT 0,
  `edited_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_chat_created` (`chat_id`,`created_at`),
  KEY `idx_sender` (`sender_id`),
  KEY `idx_messages_chat_created` (`chat_id`,`created_at`),
  KEY `idx_messages_sender_created` (`sender_id`,`created_at`),
  KEY `idx_msg_chat_id_id` (`chat_id`,`id`),
  KEY `idx_msg_sender_created` (`sender_id`,`created_at`),
  CONSTRAINT `fk_messages_chat` FOREIGN KEY (`chat_id`) REFERENCES `chats` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_messages_sender` FOREIGN KEY (`sender_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=66 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `messages`
--

LOCK TABLES `messages` WRITE;
/*!40000 ALTER TABLE `messages` DISABLE KEYS */;
INSERT INTO `messages` VALUES
(1,1,4,'hi',NULL,NULL,0,0,NULL,NULL,'2025-08-12 09:51:36'),
(2,1,4,'how are yuo?',NULL,NULL,0,0,NULL,NULL,'2025-08-12 09:51:47'),
(3,1,4,'where are you?',NULL,NULL,0,0,NULL,NULL,'2025-08-12 10:35:41'),
(4,1,4,'tui koi',NULL,NULL,0,0,NULL,NULL,'2025-08-12 10:39:02'),
(5,2,4,'hi',NULL,NULL,0,0,NULL,NULL,'2025-08-17 11:39:23'),
(6,1,4,'hgf',NULL,NULL,0,0,NULL,NULL,'2025-08-17 11:59:52'),
(7,1,4,'dsgdg',NULL,NULL,0,0,NULL,NULL,'2025-08-17 12:08:32'),
(8,1,4,'how are you?',NULL,NULL,0,0,NULL,NULL,'2025-08-17 12:21:33'),
(9,2,3,'how are you?',NULL,NULL,0,0,NULL,NULL,'2025-08-17 13:13:24'),
(10,2,4,'I\'m fine',NULL,NULL,0,0,NULL,NULL,'2025-08-17 13:14:05'),
(11,2,3,'Hi',NULL,NULL,0,0,NULL,NULL,'2025-08-17 15:13:03'),
(12,2,3,'helodsgsfd',NULL,NULL,0,0,NULL,NULL,'2025-08-17 15:13:15'),
(13,3,1,'hi',NULL,NULL,0,0,NULL,NULL,'2025-08-17 18:34:07'),
(14,3,3,'How ae you?',NULL,NULL,0,0,NULL,NULL,'2025-08-17 18:34:50'),
(15,3,3,'hi',NULL,NULL,0,0,NULL,NULL,'2025-08-17 18:42:16'),
(16,3,3,'How are you?',NULL,NULL,0,0,NULL,NULL,'2025-08-17 18:42:23'),
(17,3,1,'file',NULL,NULL,0,0,NULL,NULL,'2025-08-17 18:42:42'),
(18,3,3,'hhh',NULL,NULL,0,0,NULL,NULL,'2025-08-17 18:42:54'),
(19,2,3,'hhi',NULL,NULL,0,0,NULL,NULL,'2025-08-17 18:43:31'),
(20,3,3,'okay',NULL,NULL,0,0,NULL,NULL,'2025-08-17 18:51:38'),
(21,3,3,NULL,NULL,'http://localhost:5000/uploads/chat/130c4306cecd275d5d891dbf2c42425c.png',0,0,NULL,NULL,'2025-08-17 18:57:40'),
(22,3,3,'See the attachment',NULL,'http://localhost:5000/uploads/chat/113485e437eedfdc19935256f19b6558.pdf',0,0,NULL,NULL,'2025-08-17 19:05:26'),
(23,3,3,'Please knock me when available ',NULL,NULL,0,0,NULL,NULL,'2025-08-18 06:14:50'),
(24,2,3,'Hey',NULL,NULL,0,0,NULL,NULL,'2025-08-20 06:13:23'),
(25,2,3,'are you there?',NULL,NULL,0,0,NULL,NULL,'2025-08-20 06:13:31'),
(26,2,4,'yes',NULL,NULL,0,0,NULL,NULL,'2025-08-20 06:16:50'),
(27,2,3,'what are you doing now?',NULL,NULL,0,0,NULL,NULL,'2025-08-20 06:53:11'),
(28,1,4,'Hello from Insomnia',NULL,NULL,0,0,NULL,NULL,'2025-08-20 08:42:54'),
(29,2,3,'hi',NULL,NULL,0,0,NULL,NULL,'2025-08-20 12:07:59'),
(30,2,3,'munsi',NULL,NULL,0,0,NULL,NULL,'2025-08-20 12:08:06'),
(31,2,3,'how are you',NULL,NULL,0,0,NULL,NULL,'2025-08-20 12:08:19'),
(32,4,3,'hi',NULL,NULL,0,0,NULL,NULL,'2025-08-20 13:22:42'),
(33,4,3,NULL,NULL,'http://api.prosfata.space/uploads/chat/4d4fb65f074194381b8fe10a8ef89b94.png',0,0,NULL,NULL,'2025-08-20 13:23:02'),
(34,4,3,'Are are you?',NULL,NULL,0,0,NULL,NULL,'2025-08-20 13:23:17'),
(35,2,4,'hey',NULL,NULL,0,0,NULL,NULL,'2025-08-20 13:24:16'),
(36,2,3,'ab ku kkhk ',NULL,NULL,0,0,NULL,NULL,'2025-08-20 13:24:56'),
(37,2,3,NULL,NULL,'http://api.prosfata.space/uploads/chat/982ac7165f31f43a2da7e4223c929cb1.png',0,0,NULL,NULL,'2025-08-20 13:29:14'),
(38,5,9,'hi',NULL,NULL,0,0,NULL,NULL,'2025-09-13 07:43:10'),
(39,5,9,'hello',NULL,NULL,0,0,NULL,NULL,'2025-09-13 07:43:13'),
(40,5,9,'my name is munsi imran hossen',NULL,NULL,0,0,NULL,NULL,'2025-09-13 07:43:25'),
(41,6,9,'hi',NULL,NULL,0,0,NULL,NULL,'2025-09-13 07:44:39'),
(42,7,9,'hi',NULL,NULL,0,0,NULL,NULL,'2025-09-13 07:46:27'),
(43,9,13,'Hi',NULL,NULL,0,0,NULL,NULL,'2025-09-13 07:58:58'),
(44,2,4,'hi imran',NULL,NULL,0,0,NULL,NULL,'2025-09-14 06:00:32'),
(45,8,10,'Hello!!',NULL,NULL,0,0,NULL,NULL,'2025-09-14 06:36:10'),
(46,5,3,'okay',NULL,NULL,0,0,NULL,NULL,'2025-09-14 11:57:37'),
(47,5,3,'why you are reach out? 👹 ',NULL,NULL,0,0,NULL,NULL,'2025-09-14 11:57:58'),
(48,10,6,'Hi there?',NULL,NULL,0,0,NULL,NULL,'2025-09-16 01:01:01'),
(49,10,3,'hello norman',NULL,NULL,0,0,NULL,NULL,'2025-09-20 04:45:36'),
(50,10,3,'Hi Prosfata International',NULL,NULL,0,0,NULL,NULL,'2025-09-25 06:42:52'),
(51,1,2,'hello david',NULL,NULL,0,0,NULL,NULL,'2025-09-25 10:20:04'),
(52,1,2,'how are you',NULL,NULL,0,0,NULL,NULL,'2025-09-25 10:20:08'),
(53,12,2,'hi imran',NULL,NULL,0,0,NULL,NULL,'2025-09-25 10:27:40'),
(54,12,3,'hello',NULL,NULL,0,0,NULL,NULL,'2025-09-25 10:46:43'),
(55,10,3,'hi norman',NULL,NULL,0,0,NULL,NULL,'2025-09-25 10:46:53'),
(56,1,4,'hello bro',NULL,NULL,0,0,NULL,NULL,'2025-09-27 11:11:35'),
(57,2,4,'hello',NULL,NULL,0,0,NULL,NULL,'2025-09-27 11:11:50'),
(58,12,2,'Hi Imran',NULL,NULL,0,0,NULL,NULL,'2025-09-28 07:09:48'),
(59,1,2,'Hi Abu',NULL,NULL,0,0,NULL,NULL,'2025-09-28 07:09:59'),
(60,2,3,'hi',NULL,NULL,0,0,NULL,NULL,'2025-10-05 05:09:33'),
(61,10,3,'Hello Norman',NULL,NULL,0,0,NULL,NULL,'2025-10-05 05:09:45'),
(62,2,3,'hi\\',NULL,NULL,0,0,NULL,NULL,'2025-10-05 05:13:55'),
(63,2,3,'Hello',NULL,NULL,0,0,NULL,NULL,'2025-10-05 05:13:59'),
(64,2,4,'Hi',NULL,NULL,0,0,NULL,NULL,'2025-10-11 12:44:46'),
(65,16,6,'Hi Joshua, can you check this document I used Claude Sonnet to research and see if it aligns with your thinking? ',NULL,'http://api.prosfata.space/uploads/chat/71a6b9dd845b5e495e328a0a904d69e7.pdf',0,0,NULL,NULL,'2025-10-13 18:07:20');
/*!40000 ALTER TABLE `messages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `newsletter_subscribers`
--

DROP TABLE IF EXISTS `newsletter_subscribers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `newsletter_subscribers` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `email` varchar(255) NOT NULL,
  `status` enum('subscribed','unsubscribed','bounced') NOT NULL DEFAULT 'subscribed',
  `source` varchar(100) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_newsletter_email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `newsletter_subscribers`
--

LOCK TABLES `newsletter_subscribers` WRITE;
/*!40000 ALTER TABLE `newsletter_subscribers` DISABLE KEYS */;
INSERT INTO `newsletter_subscribers` VALUES
(1,'imranhossen1119999@gmail.com','subscribed','footer','2025-09-28 10:06:33','2025-09-28 10:06:33'),
(2,'norman@prosfata.com','subscribed','footer','2025-10-14 22:35:46','2025-10-14 22:35:46');
/*!40000 ALTER TABLE `newsletter_subscribers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notification_settings`
--

DROP TABLE IF EXISTS `notification_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `notification_settings` (
  `user_id` int(11) NOT NULL,
  `push_enabled` tinyint(1) NOT NULL DEFAULT 1,
  `email_enabled` tinyint(1) NOT NULL DEFAULT 1,
  `message_mentions` tinyint(1) NOT NULL DEFAULT 1,
  `meeting_reminders` tinyint(1) NOT NULL DEFAULT 1,
  `course_payments` tinyint(1) NOT NULL DEFAULT 1,
  `service_suggestions` tinyint(1) NOT NULL DEFAULT 0,
  `promotions` tinyint(1) NOT NULL DEFAULT 0,
  `service_updates` tinyint(1) NOT NULL DEFAULT 1,
  `subscription_renewals` tinyint(1) NOT NULL DEFAULT 1,
  `feedback_requests` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`user_id`),
  CONSTRAINT `fk_ns_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notification_settings`
--

LOCK TABLES `notification_settings` WRITE;
/*!40000 ALTER TABLE `notification_settings` DISABLE KEYS */;
INSERT INTO `notification_settings` VALUES
(1,1,1,1,1,1,0,0,1,1,1,'2025-08-20 18:53:52','2025-08-20 18:53:52'),
(2,1,1,1,1,1,0,0,1,1,1,'2025-09-25 10:30:07','2025-09-25 10:30:07'),
(3,1,1,1,1,1,0,0,1,1,1,'2025-09-12 16:50:57','2025-09-12 16:50:57'),
(4,1,1,1,1,1,0,1,1,1,1,'2025-08-20 19:02:35','2025-08-20 19:37:48'),
(6,1,1,1,1,1,0,0,1,1,1,'2025-09-13 15:04:17','2025-09-13 15:04:17'),
(7,1,1,1,1,1,0,0,1,1,1,'2025-09-13 07:22:27','2025-09-13 07:22:27'),
(8,1,1,1,1,1,0,0,1,1,1,'2025-09-13 07:32:52','2025-09-13 07:32:52'),
(9,1,1,1,1,1,0,0,1,1,1,'2025-09-13 07:34:19','2025-09-13 07:34:19'),
(10,1,1,1,1,1,0,0,1,1,1,'2025-09-13 07:35:21','2025-09-13 07:35:21'),
(11,1,1,1,1,1,0,0,1,1,1,'2025-09-13 07:39:48','2025-09-13 07:39:48'),
(12,1,1,1,1,1,0,0,1,1,1,'2025-09-13 07:56:53','2025-09-13 07:56:53'),
(13,1,1,1,1,1,0,0,1,1,1,'2025-09-13 07:57:47','2025-09-13 07:57:47'),
(14,1,1,1,1,1,0,0,1,1,1,'2025-09-13 08:19:39','2025-09-13 08:19:39'),
(15,1,1,1,1,1,0,0,1,1,1,'2025-09-28 14:56:10','2025-09-28 14:56:10'),
(16,1,1,1,1,1,0,0,1,1,1,'2025-09-28 15:25:15','2025-09-28 15:25:15'),
(17,1,1,1,1,1,0,0,1,1,1,'2025-09-28 17:26:47','2025-09-28 17:26:47'),
(18,1,1,1,1,1,0,0,1,1,1,'2025-10-12 18:03:30','2025-10-12 18:03:30');
/*!40000 ALTER TABLE `notification_settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notifications`
--

DROP TABLE IF EXISTS `notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `notifications` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `type` varchar(50) NOT NULL,
  `title` varchar(180) NOT NULL,
  `body` text DEFAULT NULL,
  `link` varchar(255) DEFAULT NULL,
  `is_read` tinyint(1) NOT NULL DEFAULT 0,
  `read_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `meta` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`meta`)),
  PRIMARY KEY (`id`),
  KEY `idx_notif_user_created` (`user_id`,`created_at`),
  KEY `idx_notif_user_unread` (`user_id`,`is_read`),
  CONSTRAINT `fk_n_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notifications`
--

LOCK TABLES `notifications` WRITE;
/*!40000 ALTER TABLE `notifications` DISABLE KEYS */;
INSERT INTO `notifications` VALUES
(1,1,'meeting_reminder','Your meeting starts soon','Join the call in 15 minutes','http://localhost:5173/meetings/123',0,NULL,'2025-08-20 18:53:52',NULL),
(2,4,'meeting_reminder','Your meeting starts soon','Join the call in 15 minutes','http://localhost:5173/meetings/123',1,'2025-08-20 19:42:01','2025-08-20 19:02:35',NULL),
(3,4,'meeting_reminder','Your meeting starts soon','Join the call in 15 minutes','http://localhost:5173/meetings/123',1,'2025-09-25 10:31:26','2025-08-20 19:42:28',NULL),
(4,4,'meeting_reminder','Your meeting starts soon','Join the call in 15 minutes','http://localhost:5173/meetings/123',1,'2025-09-25 10:31:20','2025-08-20 19:42:44',NULL);
/*!40000 ALTER TABLE `notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `order_earnings`
--

DROP TABLE IF EXISTS `order_earnings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_earnings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `order_id` int(11) NOT NULL,
  `expert_id` int(11) NOT NULL,
  `gross_amount` decimal(12,2) NOT NULL,
  `platform_fee` decimal(12,2) NOT NULL DEFAULT 0.00,
  `processing_fee` decimal(12,2) NOT NULL DEFAULT 0.00,
  `net_amount` decimal(12,2) NOT NULL,
  `currency` char(3) NOT NULL DEFAULT 'USD',
  `captured_at` datetime DEFAULT NULL,
  `delivered_at` datetime DEFAULT NULL,
  `hold_until` datetime DEFAULT NULL,
  `released_at` datetime DEFAULT NULL,
  `status` enum('PENDING','HELD','AVAILABLE','PAID','REFUNDED','CANCELED') NOT NULL DEFAULT 'PENDING',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `order_id` (`order_id`),
  KEY `idx_earn_expert_status` (`expert_id`,`status`),
  CONSTRAINT `fk_earn_expert` FOREIGN KEY (`expert_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_earn_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_earnings`
--

LOCK TABLES `order_earnings` WRITE;
/*!40000 ALTER TABLE `order_earnings` DISABLE KEYS */;
/*!40000 ALTER TABLE `order_earnings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `order_payments`
--

DROP TABLE IF EXISTS `order_payments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_payments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `order_id` int(11) NOT NULL,
  `payment_intent_id` varchar(191) NOT NULL,
  `status` varchar(64) NOT NULL,
  `amount_cents` int(11) NOT NULL,
  `currency` char(3) NOT NULL,
  `receipt_url` varchar(512) DEFAULT NULL,
  `payment_method_brand` varchar(64) DEFAULT NULL,
  `payment_method_last4` varchar(8) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `order_id` (`order_id`),
  KEY `payment_intent_id` (`payment_intent_id`),
  CONSTRAINT `fk_op_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_payments`
--

LOCK TABLES `order_payments` WRITE;
/*!40000 ALTER TABLE `order_payments` DISABLE KEYS */;
/*!40000 ALTER TABLE `order_payments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `orders`
--

DROP TABLE IF EXISTS `orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `orders` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `kind` enum('service','course','coaching') NOT NULL,
  `ref_id` int(11) NOT NULL,
  `amount_cents` int(11) NOT NULL,
  `currency` char(3) NOT NULL DEFAULT 'usd',
  `status` enum('draft','requires_payment','processing','paid','failed','refunded','canceled') NOT NULL DEFAULT 'draft',
  `description` varchar(255) DEFAULT NULL,
  `stripe_customer_id` varchar(191) DEFAULT NULL,
  `payment_intent_id` varchar(191) DEFAULT NULL,
  `payment_method_id` varchar(191) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `kind` (`kind`,`ref_id`),
  KEY `status` (`status`),
  KEY `payment_intent_id` (`payment_intent_id`),
  CONSTRAINT `fk_orders_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orders`
--

LOCK TABLES `orders` WRITE;
/*!40000 ALTER TABLE `orders` DISABLE KEYS */;
/*!40000 ALTER TABLE `orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pages`
--

DROP TABLE IF EXISTS `pages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `pages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(120) NOT NULL,
  `path` varchar(255) DEFAULT NULL,
  `icon` varchar(64) DEFAULT NULL,
  `order_num` int(11) NOT NULL DEFAULT 999,
  `is_menu` tinyint(1) NOT NULL DEFAULT 1,
  `parent_id` int(11) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_pages_path` (`path`),
  KEY `idx_pages_parent` (`parent_id`),
  CONSTRAINT `fk_pages_parent` FOREIGN KEY (`parent_id`) REFERENCES `pages` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=56 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pages`
--

LOCK TABLES `pages` WRITE;
/*!40000 ALTER TABLE `pages` DISABLE KEYS */;
INSERT INTO `pages` VALUES
(1,'Dashboard','/dashboard','layout-dashboard',1,1,NULL,1,'2025-08-13 08:39:39','2025-08-13 08:39:39'),
(2,'Expert Dashboard','/expert/dashboard','layout-dashboard',2,1,NULL,1,'2025-08-13 08:39:39','2025-08-13 20:14:52'),
(3,'Resume Review','/resume','file-check',3,1,NULL,1,'2025-08-13 08:39:39','2025-08-13 08:39:39'),
(4,'Courses & Events','/course-events','monitor-play',4,1,NULL,1,'2025-08-13 08:39:39','2025-08-14 03:29:46'),
(5,'Service Hub','/services','briefcase',5,1,NULL,1,'2025-08-13 08:39:39','2025-08-13 08:39:39'),
(6,'Find an Expert','/find-an-expert','graduation-cap',6,1,NULL,1,'2025-08-13 08:39:39','2025-08-14 03:33:09'),
(7,'My Network','/my-network','earth',7,1,NULL,1,'2025-08-13 08:39:39','2025-08-14 03:34:20'),
(8,'Messages','/messages','messages-square',2,1,NULL,1,'2025-08-13 08:39:39','2025-09-13 17:21:29'),
(9,'My Calendar','/my-calendar','calendar-days',3,1,NULL,1,'2025-08-13 08:39:39','2025-10-11 17:14:49'),
(10,'Job Board','/jobs','list',10,1,NULL,1,'2025-08-13 08:39:39','2025-08-13 08:39:39'),
(11,'Orders','/payments','credit-card',11,1,NULL,1,'2025-08-13 08:39:39','2025-09-13 15:02:37'),
(12,'Settings','/settings','settings',12,1,NULL,1,'2025-08-13 08:39:39','2025-08-13 08:39:39'),
(16,'Admin Setting','/admin-setting','calendar-cog',16,1,NULL,1,'2025-08-13 19:40:46','2025-08-13 20:49:31'),
(17,'Page List','/menu-page-list','layout-panel-top',1,1,16,1,'2025-08-13 19:44:02','2025-08-13 20:47:41'),
(18,'Role List','/user-role-list','globe-lock',2,1,16,1,'2025-08-13 19:45:14','2025-08-13 20:47:12'),
(19,'Role Permission','/role-page-access','shield-alert',2,1,16,1,'2025-08-13 19:46:08','2025-08-13 20:48:13'),
(20,'Category List','/category-list','clipboard-list',6,1,16,1,'2025-08-13 20:44:05','2025-08-13 20:44:05'),
(21,'My Availability','/my-availability','timer-reset',999,1,6,1,'2025-08-15 06:34:08','2025-08-15 06:34:08'),
(22,'Create Services','/services/create','package-plus',999,1,5,1,'2025-08-15 13:17:22','2025-08-15 13:17:22'),
(23,'My Services','/my-services','shopping-cart',1,1,5,1,'2025-08-15 13:19:45','2025-08-15 13:22:21'),
(24,'All Experts','/find-an-expert','book-open-text',1,1,6,1,'2025-08-15 15:04:15','2025-08-15 15:04:15'),
(25,'All Services','/services','gift',1,1,5,1,'2025-08-15 16:37:45','2025-08-15 16:37:45'),
(26,'All Courses & Events','/course-events','calendar-sync',1,1,4,1,'2025-08-16 06:51:35','2025-08-16 06:51:35'),
(27,'Create New Course','/course-events/create','diamond-plus',3,1,4,1,'2025-08-16 07:15:04','2025-08-16 07:15:04'),
(28,'My Courses','/my-courses','school',2,1,4,1,'2025-08-16 07:15:58','2025-08-16 07:15:58'),
(29,'My Courses','/learning','book-open-check',3,1,30,1,'2025-08-17 05:08:25','2025-08-19 08:53:29'),
(30,'My Accounts','/','baggage-claim',9,1,NULL,1,'2025-08-19 08:52:24','2025-08-19 13:38:17'),
(31,'My Meeting History','/meetings/history/my','calendar-days',3,1,30,1,'2025-08-19 08:55:31','2025-08-19 13:39:51'),
(32,'Services Meeting History','/meetings/history/expert','calendar-clock',6,1,30,1,'2025-08-19 13:41:27','2025-08-19 13:41:27'),
(33,'Experts Meeting History','/meetings/history/admin','calendar-search',7,1,30,1,'2025-08-19 13:42:09','2025-08-19 13:42:09'),
(34,'Coaching','/coaching/catalog','book-open-check',4,1,NULL,1,'2025-08-23 14:05:45','2025-09-13 17:23:34'),
(35,'All Coaching Programs','/coaching/catalog','notebook-text',1,1,34,1,'2025-08-23 14:07:02','2025-08-23 20:41:51'),
(36,'My Programs','/coaching/my-programs','list-ordered',2,1,34,1,'2025-08-23 14:08:51','2025-08-23 20:42:34'),
(37,'Create Program','/coaching/programs/new','plus-circle',3,1,34,1,'2025-08-23 20:43:29','2025-08-23 20:43:29'),
(38,'My Availability','/my-availability','calendar-clock',3,1,NULL,1,'2025-08-23 20:44:56','2025-09-13 17:22:22'),
(39,'Reviews (Assignments)','/coaching/review','clipboard-list',5,1,34,1,'2025-08-23 20:45:59','2025-08-23 20:45:59'),
(40,'Meetings (Expert)','/meetings/history/expert','clock',6,1,34,1,'2025-08-23 20:46:52','2025-08-23 20:46:52'),
(41,'Browse Programs','/coaching/catalog','notebook-text',7,1,34,1,'2025-08-23 20:48:35','2025-08-23 20:48:35'),
(42,'My Enrollments','/coaching/enrollments','user-round',8,1,34,1,'2025-08-23 20:49:25','2025-08-23 20:49:25'),
(44,'Roadmap & Assignments','/coaching/assignments','list-ordered',10,1,34,1,'2025-08-23 20:51:33','2025-08-23 20:51:33'),
(45,'My Meetings','/meetings/history/my','clock',11,1,34,1,'2025-08-23 20:52:36','2025-08-23 20:52:36'),
(46,'User Management','/admin/users','user-round-cog',3,1,16,1,'2025-08-24 07:50:39','2025-08-24 07:50:39'),
(47,'Payout','/payout/wallet','landmark',10,1,NULL,1,'2025-09-07 19:03:50','2025-09-07 19:17:09'),
(48,'Overview','/payout/overview','folder-kanban',1,1,47,1,'2025-09-07 19:04:54','2025-09-07 19:04:54'),
(49,'Payouts Settings','/admin/payouts-settings','settings-2',3,1,47,1,'2025-09-07 19:07:14','2025-09-07 19:17:47'),
(50,'Expert Payouts','/admin/payouts','banknote',2,1,47,1,'2025-09-07 19:08:08','2025-09-07 19:18:51'),
(51,'My Blogs','/blogs/my','blocks',10,1,NULL,1,'2025-09-26 21:14:05','2025-09-26 21:14:05'),
(52,'Own Blogs Post','/blogs/my','notebook',1,1,51,1,'2025-09-26 21:14:34','2025-09-26 21:14:34'),
(53,'Post Moderation','/blogs/moderation','file-sliders',2,1,51,1,'2025-09-26 21:15:05','2025-09-26 21:15:05'),
(54,'Categories','/blogs/categories','boxes',3,1,51,1,'2025-09-26 21:15:47','2025-09-26 21:15:47'),
(55,'Comments Moderation','/blogs/comments-moderation','messages-square',4,1,51,1,'2025-09-27 08:37:49','2025-09-27 08:37:49');
/*!40000 ALTER TABLE `pages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `password_reset_tokens`
--

DROP TABLE IF EXISTS `password_reset_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `password_reset_tokens` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `token_hash` char(64) NOT NULL,
  `expires_at` datetime NOT NULL,
  `used` tinyint(1) DEFAULT 0,
  `used_at` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `token_hash` (`token_hash`),
  UNIQUE KEY `uq_prt_token` (`token_hash`),
  KEY `user_id` (`user_id`),
  KEY `idx_prt_expires` (`expires_at`),
  CONSTRAINT `fk_prt_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `password_reset_tokens`
--

LOCK TABLES `password_reset_tokens` WRITE;
/*!40000 ALTER TABLE `password_reset_tokens` DISABLE KEYS */;
INSERT INTO `password_reset_tokens` VALUES
(1,3,'0991a70f7bab68a19f284834d7cb94525979f29becb22c472ec474035dd7593b','2025-08-10 15:54:30',0,NULL,'2025-08-10 08:54:30'),
(3,7,'f60409607c35d9f80b109e29a4d11a697b2b03e3f86f1401a001b81c9209f3ef','2025-09-13 08:23:10',0,NULL,'2025-09-13 07:23:10'),
(8,6,'012930abeb5ff7b2d8528e993df0d3c61257c59fda6e21efc4d14753b09d8f22','2025-09-20 16:48:05',1,'2025-09-20 15:55:46','2025-09-20 15:48:05'),
(10,17,'d54cb073d4f9e6c594101e6b2bf7473b3d296daaafa5e47ef5e03ca861a2d5fc','2025-10-05 16:40:18',0,NULL,'2025-10-05 15:40:18'),
(11,15,'a5ec7a7c3158b469e3fe3239a9af5e3d7cfc7090fbffb617f12de56d7dbab34e','2025-10-05 16:44:22',1,'2025-10-05 15:45:51','2025-10-05 15:44:22');
/*!40000 ALTER TABLE `password_reset_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payment_webhook_events`
--

DROP TABLE IF EXISTS `payment_webhook_events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `payment_webhook_events` (
  `id` varchar(191) NOT NULL,
  `provider` enum('stripe') NOT NULL,
  `received_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payment_webhook_events`
--

LOCK TABLES `payment_webhook_events` WRITE;
/*!40000 ALTER TABLE `payment_webhook_events` DISABLE KEYS */;
/*!40000 ALTER TABLE `payment_webhook_events` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payout_accounts`
--

DROP TABLE IF EXISTS `payout_accounts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `payout_accounts` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) NOT NULL,
  `method` enum('BANK','WISE','PAYONEER','BKASH','NAGAD','PAYPAL') NOT NULL,
  `details` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`details`)),
  `is_default` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_method` (`user_id`,`method`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payout_accounts`
--

LOCK TABLES `payout_accounts` WRITE;
/*!40000 ALTER TABLE `payout_accounts` DISABLE KEYS */;
/*!40000 ALTER TABLE `payout_accounts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payout_methods`
--

DROP TABLE IF EXISTS `payout_methods`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `payout_methods` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `method` enum('BANK_TRANSFER','WISE','PAYONEER','BKASH','PAYPAL','MANUAL') NOT NULL,
  `is_default` tinyint(1) NOT NULL DEFAULT 0,
  `details_json` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`details_json`)),
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_payout_methods_user` (`user_id`),
  CONSTRAINT `fk_payout_methods_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payout_methods`
--

LOCK TABLES `payout_methods` WRITE;
/*!40000 ALTER TABLE `payout_methods` DISABLE KEYS */;
INSERT INTO `payout_methods` VALUES
(1,4,'PAYPAL',0,'{\"email\": \"founder@example.com\"}','2025-09-11 20:23:59','2025-09-11 20:23:59',NULL),
(2,3,'PAYPAL',0,'{\"email\": \"imranhossen1119999@gmail.com\\r\\n\"}','2025-09-11 20:25:08','2025-09-11 20:25:08',NULL),
(3,3,'BKASH',0,'{\"account_holder_name\":\"\",\"bank_name\":\"\",\"bank_country\":\"US\",\"currency\":\"USD\",\"iban\":\"\",\"account_number\":\"\",\"routing_number\":\"\",\"swift_bic\":\"\",\"email\":\"\",\"recipient_id\":\"\",\"customer_id\":\"\",\"phone\":\"01925325050\",\"full_name\":\"ABU\",\"instructions\":\"\",\"note\":\"\"}','2025-09-11 20:34:00','2025-09-11 20:34:00',NULL),
(4,3,'PAYONEER',0,'{\"account_holder_name\":\"\",\"bank_name\":\"\",\"bank_country\":\"US\",\"currency\":\"USD\",\"iban\":\"\",\"account_number\":\"\",\"routing_number\":\"\",\"swift_bic\":\"\",\"email\":\"abutaleb142@gmail.com\",\"recipient_id\":\"\",\"customer_id\":\"4\",\"phone\":\"\",\"full_name\":\"ABU\",\"instructions\":\"\",\"note\":\"3\"}','2025-09-13 14:28:34','2025-09-13 14:28:34',NULL);
/*!40000 ALTER TABLE `payout_methods` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payout_requests`
--

DROP TABLE IF EXISTS `payout_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `payout_requests` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `amount` decimal(12,2) NOT NULL,
  `currency` char(3) NOT NULL DEFAULT 'USD',
  `status` enum('PENDING','APPROVED','PAID','REJECTED','CANCELED') NOT NULL DEFAULT 'PENDING',
  `reason` varchar(255) DEFAULT NULL,
  `method` enum('BANK','BKASH','NAGAD','PAYPAL','STRIPE_CONNECT','OTHER') NOT NULL DEFAULT 'BANK',
  `details` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`details`)),
  `requested_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `approved_at` datetime DEFAULT NULL,
  `processed_at` datetime DEFAULT NULL,
  `processed_by` int(11) DEFAULT NULL,
  `reference` varchar(128) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_payout_user_status` (`user_id`,`status`,`requested_at`),
  KEY `fk_payout_processed_by` (`processed_by`),
  CONSTRAINT `fk_payout_processed_by` FOREIGN KEY (`processed_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_payout_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payout_requests`
--

LOCK TABLES `payout_requests` WRITE;
/*!40000 ALTER TABLE `payout_requests` DISABLE KEYS */;
INSERT INTO `payout_requests` VALUES
(1,3,37.00,'USD','PAID',NULL,'BANK','{}','2025-09-07 20:23:22','2025-09-08 02:24:50','2025-09-08 02:24:55',4,'TXN_1757276695169','2025-09-07 20:50:08'),
(2,3,20.00,'USD','REJECTED',NULL,'BKASH','{\"wallet_number\":\"Abu\",\"holder_name\":\"132442442\",\"note\":\"test\"}','2025-09-07 20:50:18',NULL,'2025-09-08 03:04:06',4,NULL,'2025-09-07 20:50:18'),
(3,3,25.00,'USD','REJECTED',NULL,'NAGAD','{\"wallet_number\":\"Abu\",\"holder_name\":\"35436346\",\"note\":\"hi\"}','2025-09-07 20:51:17',NULL,'2025-09-08 03:04:05',4,NULL,'2025-09-07 20:51:17'),
(6,3,25.00,'USD','PAID',NULL,'NAGAD','{}','2025-09-07 20:59:03','2025-09-08 03:03:57','2025-09-08 03:05:03',4,'TXN_1757279103793','2025-09-07 20:59:03'),
(7,3,20.00,'USD','PAID',NULL,'NAGAD','{\"wallet_number\":\"3534643\",\"holder_name\":\"Abu\",\"note\":\"fhf\"}','2025-09-07 21:16:04',NULL,'2025-09-08 03:23:27',NULL,'TXN_1757280207059','2025-09-07 21:16:04'),
(8,3,30.00,'USD','PAID',NULL,'PAYPAL','{\"email\":\"imranhossen1119999@gmail.com\",\"note\":\"hi\"}','2025-09-07 21:59:19',NULL,'2025-09-08 04:01:47',4,'TXN_1757282507722','2025-09-07 21:59:19'),
(9,3,20.00,'USD','PAID',NULL,'PAYPAL','{\"email\":\"imranhossen1119999@gmail.com\\r\\n\"}','2025-09-12 05:37:01',NULL,'2025-09-12 12:56:40',NULL,'test','2025-09-12 05:37:01'),
(10,3,50.00,'USD','PAID',NULL,'PAYPAL','{\"email\":\"i••••••••••••••••9@gmail.com\\r\\n\"}','2025-09-13 14:29:10',NULL,'2025-09-13 14:37:09',NULL,'56395923','2025-09-13 14:29:10'),
(11,3,30.00,'USD','PENDING',NULL,'PAYPAL','{\"email\":\"i••••••••••••••••9@gmail.com\\r\\n\"}','2025-10-05 07:34:09',NULL,NULL,NULL,NULL,'2025-10-05 07:34:09');
/*!40000 ALTER TABLE `payout_requests` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payouts`
--

DROP TABLE IF EXISTS `payouts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `payouts` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `request_id` bigint(20) unsigned NOT NULL,
  `user_id` bigint(20) unsigned NOT NULL,
  `amount` decimal(12,2) NOT NULL,
  `currency` char(3) NOT NULL DEFAULT 'USD',
  `method` varchar(64) NOT NULL,
  `reference` varchar(128) DEFAULT NULL,
  `details` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`details`)),
  `paid_at` datetime NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_request_id` (`request_id`),
  KEY `k_user_paid` (`user_id`,`paid_at`),
  CONSTRAINT `fk_payout_request` FOREIGN KEY (`request_id`) REFERENCES `payout_requests` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payouts`
--

LOCK TABLES `payouts` WRITE;
/*!40000 ALTER TABLE `payouts` DISABLE KEYS */;
INSERT INTO `payouts` VALUES
(1,7,3,20.00,'USD','NAGAD','TXN_1757280207059','{\"method_details\":{\"note\":\"\"},\"fees\":{\"currency\":\"USD\",\"gross\":20,\"fee_platform\":0,\"fee_processing_pct\":0.58,\"fee_processing_fixed\":0.3,\"fee_total\":0.88,\"net_to_expert\":19.12}}','2025-09-08 03:23:27','2025-09-07 21:23:27'),
(2,8,3,30.00,'USD','PAYPAL','TXN_1757282507722','{\"method_details\":{\"note\":\"\"}}','2025-09-08 04:01:47','2025-09-07 22:01:47'),
(3,9,3,20.00,'USD','PAYPAL','test','{\"method_details\":{\"note\":\"payout\",\"method\":\"PAYPAL\",\"saved_id\":2,\"details\":{\"email\":\"imranhossen1119999@gmail.com\\r\\n\"}},\"fees\":{\"currency\":\"USD\",\"gross\":20,\"fee_platform\":0,\"fee_processing_pct\":0.58,\"fee_processing_fixed\":0.4,\"fee_total\":0.98,\"net_to_expert\":19.02},\"stripe_transfer_id\":null,\"stripe_payout_id\":null}','2025-09-12 12:56:40','2025-09-12 06:56:40'),
(4,10,3,50.00,'USD','PAYPAL','56395923','{\"method_details\":{\"note\":\"note\",\"method\":\"PAYPAL\",\"saved_id\":2,\"details\":{\"email\":\"imranhossen1119999@gmail.com\\r\\n\"}},\"fees\":{\"currency\":\"USD\",\"gross\":50,\"fee_platform\":0,\"fee_processing_pct\":0.95,\"fee_processing_fixed\":0.4,\"fee_total\":1.35,\"net_to_expert\":48.65},\"stripe_transfer_id\":null,\"stripe_payout_id\":null}','2025-09-13 14:37:09','2025-09-13 14:37:09');
/*!40000 ALTER TABLE `payouts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `platform_ledger`
--

DROP TABLE IF EXISTS `platform_ledger`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `platform_ledger` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) unsigned DEFAULT NULL,
  `kind` varchar(32) NOT NULL,
  `amount` decimal(12,2) NOT NULL,
  `currency` char(3) NOT NULL DEFAULT 'USD',
  `ref_table` varchar(64) DEFAULT NULL,
  `ref_id` bigint(20) unsigned DEFAULT NULL,
  `meta` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`meta`)),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_pl_event` (`kind`,`ref_table`,`ref_id`),
  KEY `k_kind` (`kind`),
  KEY `k_created` (`created_at`),
  KEY `k_user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=62 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `platform_ledger`
--

LOCK TABLES `platform_ledger` WRITE;
/*!40000 ALTER TABLE `platform_ledger` DISABLE KEYS */;
INSERT INTO `platform_ledger` VALUES
(1,NULL,'SALE_GROSS',19.99,'USD','service_orders',5,NULL,'2025-08-11 19:21:19'),
(2,NULL,'FEE_PLATFORM',2.00,'USD','service_orders',5,NULL,'2025-08-11 19:21:19'),
(3,NULL,'FEE_PROCESSING',0.88,'USD','service_orders',5,NULL,'2025-08-11 19:21:19'),
(4,NULL,'SALE_GROSS',49.99,'USD','service_orders',6,NULL,'2025-08-14 19:44:31'),
(5,NULL,'FEE_PLATFORM',5.00,'USD','service_orders',6,NULL,'2025-08-14 19:44:31'),
(6,NULL,'FEE_PROCESSING',1.75,'USD','service_orders',6,NULL,'2025-08-14 19:44:31'),
(7,NULL,'SALE_GROSS',19.99,'USD','service_orders',36,NULL,'2025-08-16 06:52:01'),
(8,NULL,'FEE_PLATFORM',2.00,'USD','service_orders',36,NULL,'2025-08-16 06:52:01'),
(9,NULL,'FEE_PROCESSING',0.88,'USD','service_orders',36,NULL,'2025-08-16 06:52:01'),
(10,NULL,'SALE_GROSS',19.99,'USD','service_orders',39,NULL,'2025-08-16 07:40:17'),
(11,NULL,'FEE_PLATFORM',2.00,'USD','service_orders',39,NULL,'2025-08-16 07:40:17'),
(12,NULL,'FEE_PROCESSING',0.88,'USD','service_orders',39,NULL,'2025-08-16 07:40:17'),
(13,NULL,'SALE_GROSS',10.00,'USD','service_orders',41,NULL,'2025-08-19 14:29:59'),
(14,NULL,'FEE_PLATFORM',1.00,'USD','service_orders',41,NULL,'2025-08-19 14:29:59'),
(15,NULL,'FEE_PROCESSING',0.59,'USD','service_orders',41,NULL,'2025-08-19 14:29:59'),
(16,NULL,'SALE_GROSS',19.99,'USD','service_orders',50,NULL,'2025-09-01 20:44:43'),
(17,NULL,'FEE_PLATFORM',2.00,'USD','service_orders',50,NULL,'2025-09-01 20:44:43'),
(18,NULL,'FEE_PROCESSING',0.88,'USD','service_orders',50,NULL,'2025-09-01 20:44:43'),
(19,NULL,'SALE_GROSS',10.00,'USD','service_orders',53,NULL,'2025-09-07 10:47:18'),
(20,NULL,'FEE_PLATFORM',1.00,'USD','service_orders',53,NULL,'2025-09-07 10:47:18'),
(21,NULL,'FEE_PROCESSING',0.59,'USD','service_orders',53,NULL,'2025-09-07 10:47:18'),
(22,NULL,'SALE_GROSS',10.00,'USD','service_orders',55,NULL,'2025-09-07 12:24:13'),
(23,NULL,'FEE_PLATFORM',1.00,'USD','service_orders',55,NULL,'2025-09-07 12:24:13'),
(24,NULL,'FEE_PROCESSING',0.59,'USD','service_orders',55,NULL,'2025-09-07 12:24:13'),
(25,NULL,'SALE_GROSS',29.00,'USD','service_orders',56,NULL,'2025-09-07 14:50:26'),
(26,NULL,'FEE_PLATFORM',2.90,'USD','service_orders',56,NULL,'2025-09-07 14:50:26'),
(27,NULL,'FEE_PROCESSING',1.14,'USD','service_orders',56,NULL,'2025-09-07 14:50:26'),
(28,NULL,'SALE_GROSS',20.00,'USD','course_orders',1,NULL,'2025-08-19 12:21:16'),
(29,NULL,'FEE_PLATFORM',2.00,'USD','course_orders',1,NULL,'2025-08-19 12:21:16'),
(30,NULL,'FEE_PROCESSING',0.88,'USD','course_orders',1,NULL,'2025-08-19 12:21:16'),
(31,NULL,'SALE_GROSS',20.00,'USD','course_orders',5,NULL,'2025-09-07 17:39:59'),
(32,NULL,'FEE_PLATFORM',2.00,'USD','course_orders',5,NULL,'2025-09-07 17:39:59'),
(33,NULL,'FEE_PROCESSING',0.88,'USD','course_orders',5,NULL,'2025-09-07 17:39:59'),
(34,NULL,'SALE_GROSS',20.00,'USD','course_orders',7,NULL,'2025-09-07 16:38:50'),
(35,NULL,'FEE_PLATFORM',2.00,'USD','course_orders',7,NULL,'2025-09-07 16:38:50'),
(36,NULL,'FEE_PROCESSING',0.88,'USD','course_orders',7,NULL,'2025-09-07 16:38:50'),
(37,NULL,'SALE_GROSS',49.00,'USD','course_orders',13,NULL,'2025-09-07 16:03:58'),
(38,NULL,'FEE_PLATFORM',4.90,'USD','course_orders',13,NULL,'2025-09-07 16:03:58'),
(39,NULL,'FEE_PROCESSING',1.72,'USD','course_orders',13,NULL,'2025-09-07 16:03:58'),
(40,NULL,'SALE_GROSS',20.00,'USD','coaching_orders',6,NULL,'2025-09-01 07:35:08'),
(41,NULL,'FEE_PLATFORM',2.00,'USD','coaching_orders',6,NULL,'2025-09-01 07:35:08'),
(42,NULL,'FEE_PROCESSING',0.88,'USD','coaching_orders',6,NULL,'2025-09-01 07:35:08'),
(43,NULL,'SALE_GROSS',20.00,'USD','coaching_orders',7,NULL,'2025-09-01 07:23:49'),
(44,NULL,'FEE_PLATFORM',2.00,'USD','coaching_orders',7,NULL,'2025-09-01 07:23:49'),
(45,NULL,'FEE_PROCESSING',0.88,'USD','coaching_orders',7,NULL,'2025-09-01 07:23:49'),
(46,NULL,'SALE_GROSS',20.00,'USD','coaching_orders',9,NULL,'2025-09-01 18:50:48'),
(47,NULL,'FEE_PLATFORM',2.00,'USD','coaching_orders',9,NULL,'2025-09-01 18:50:48'),
(48,NULL,'FEE_PROCESSING',0.88,'USD','coaching_orders',9,NULL,'2025-09-01 18:50:48'),
(49,NULL,'SALE_GROSS',20.00,'USD','coaching_orders',10,NULL,'2025-09-01 17:24:04'),
(50,NULL,'FEE_PLATFORM',2.00,'USD','coaching_orders',10,NULL,'2025-09-01 17:24:04'),
(51,NULL,'FEE_PROCESSING',0.88,'USD','coaching_orders',10,NULL,'2025-09-01 17:24:04'),
(52,NULL,'SALE_GROSS',20.00,'USD','coaching_orders',11,NULL,'2025-09-01 16:01:42'),
(53,NULL,'FEE_PLATFORM',2.00,'USD','coaching_orders',11,NULL,'2025-09-01 16:01:42'),
(54,NULL,'FEE_PROCESSING',0.88,'USD','coaching_orders',11,NULL,'2025-09-01 16:01:42'),
(55,NULL,'SALE_GROSS',20.00,'USD','coaching_orders',13,NULL,'2025-09-01 18:00:28'),
(56,NULL,'FEE_PLATFORM',2.00,'USD','coaching_orders',13,NULL,'2025-09-01 18:00:28'),
(57,NULL,'FEE_PROCESSING',0.88,'USD','coaching_orders',13,NULL,'2025-09-01 18:00:28'),
(58,NULL,'SALE_GROSS',20.00,'USD','coaching_orders',15,NULL,'2025-09-07 08:45:16'),
(59,NULL,'FEE_PLATFORM',2.00,'USD','coaching_orders',15,NULL,'2025-09-07 08:45:16'),
(60,NULL,'FEE_PROCESSING',0.88,'USD','coaching_orders',15,NULL,'2025-09-07 08:45:16'),
(61,3,'PAYOUT_OUT',30.00,'USD','payout_requests',8,NULL,'2025-09-07 22:01:47');
/*!40000 ALTER TABLE `platform_ledger` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `role_page_permissions`
--

DROP TABLE IF EXISTS `role_page_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `role_page_permissions` (
  `role_id` int(11) NOT NULL,
  `page_id` int(11) NOT NULL,
  `can_view` tinyint(1) NOT NULL DEFAULT 0,
  `can_create` tinyint(1) NOT NULL DEFAULT 0,
  `can_update` tinyint(1) NOT NULL DEFAULT 0,
  `can_delete` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`role_id`,`page_id`),
  KEY `fk_rpp_page` (`page_id`),
  CONSTRAINT `fk_rpp_page` FOREIGN KEY (`page_id`) REFERENCES `pages` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_rpp_role` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `role_page_permissions`
--

LOCK TABLES `role_page_permissions` WRITE;
/*!40000 ALTER TABLE `role_page_permissions` DISABLE KEYS */;
INSERT INTO `role_page_permissions` VALUES
(1,1,1,1,0,0),
(1,4,1,1,0,0),
(1,5,1,1,0,0),
(1,6,1,1,0,0),
(1,7,1,0,0,0),
(1,8,1,1,1,1),
(1,9,1,1,1,1),
(1,11,1,1,1,0),
(1,12,1,1,1,1),
(1,16,1,1,1,1),
(1,17,1,1,1,1),
(1,18,1,1,1,1),
(1,19,1,1,1,1),
(1,20,1,1,1,1),
(1,21,1,1,1,1),
(1,22,1,1,1,1),
(1,23,1,1,1,1),
(1,24,1,1,1,1),
(1,25,1,1,1,1),
(1,26,1,1,0,0),
(1,28,1,1,0,0),
(1,29,1,1,1,1),
(1,30,1,1,1,1),
(1,31,1,1,1,1),
(1,33,1,1,1,1),
(1,34,1,0,0,0),
(1,35,1,0,0,0),
(1,36,1,0,0,0),
(1,37,1,0,0,0),
(1,39,1,0,0,0),
(1,40,1,0,0,0),
(1,41,1,0,0,0),
(1,42,1,0,0,0),
(1,44,1,0,0,0),
(1,45,1,0,0,0),
(1,46,1,1,1,1),
(1,47,1,1,1,0),
(1,48,1,1,1,0),
(1,49,1,1,1,0),
(1,50,1,1,1,0),
(1,51,1,1,1,1),
(1,52,1,1,1,1),
(1,53,1,1,1,1),
(1,54,1,1,1,1),
(1,55,1,1,1,1),
(2,1,1,0,0,0),
(2,4,1,1,1,1),
(2,5,1,1,1,1),
(2,6,1,1,1,1),
(2,7,1,1,1,1),
(2,8,1,1,1,1),
(2,9,1,1,1,1),
(2,11,1,1,1,1),
(2,12,1,1,1,1),
(2,21,1,1,1,1),
(2,22,1,1,1,1),
(2,23,1,1,1,1),
(2,24,1,1,1,1),
(2,25,1,1,1,1),
(2,26,1,1,0,0),
(2,28,1,1,1,1),
(2,29,1,1,1,1),
(2,30,1,1,1,0),
(2,31,1,1,1,1),
(2,32,1,1,1,1),
(2,34,1,1,1,1),
(2,35,1,1,1,1),
(2,36,1,1,1,1),
(2,37,1,1,1,1),
(2,39,1,1,1,1),
(2,40,1,1,1,1),
(2,47,1,1,1,1),
(2,51,1,1,1,1),
(5,1,1,0,0,0),
(5,4,1,0,0,0),
(5,5,1,0,0,0),
(5,6,1,0,0,0),
(5,7,1,0,0,0),
(5,8,1,0,0,0),
(5,9,1,0,0,0),
(5,11,1,0,0,0),
(5,12,1,0,0,0),
(5,29,1,0,0,0),
(5,30,1,1,1,1),
(5,31,1,0,0,0),
(5,34,1,1,1,1),
(5,41,1,1,1,1),
(5,42,1,1,1,1),
(5,44,1,1,1,1),
(5,45,1,1,1,1);
/*!40000 ALTER TABLE `role_page_permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `roles`
--

DROP TABLE IF EXISTS `roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `roles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `slug` varchar(60) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `roles`
--

LOCK TABLES `roles` WRITE;
/*!40000 ALTER TABLE `roles` DISABLE KEYS */;
INSERT INTO `roles` VALUES
(1,'Administrator','admin','2025-08-13 08:37:05','2025-08-13 08:39:13'),
(2,'Expert','expert','2025-08-13 08:37:05','2025-08-13 08:38:20'),
(4,'Reviewer','reviewer','2025-08-13 08:37:55','2025-08-13 08:37:55'),
(5,'User','user','2025-08-13 08:37:55','2025-08-13 08:37:55');
/*!40000 ALTER TABLE `roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `service_orders`
--

DROP TABLE IF EXISTS `service_orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `service_orders` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `expert_id` int(11) NOT NULL,
  `service_id` int(11) NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `currency` varchar(10) DEFAULT 'USD',
  `status` enum('pending','paid','cancelled','refunded') NOT NULL DEFAULT 'pending',
  `cancelled_at` datetime DEFAULT NULL,
  `cancelled_by` int(11) DEFAULT NULL,
  `cancelled_reason` varchar(255) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `payment_ref` varchar(100) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `slot_id` int(11) DEFAULT NULL,
  `payment_status` enum('Pending','Paid','Failed') DEFAULT 'Pending',
  `meeting_id` int(11) DEFAULT NULL,
  `stripe_payment_intent_id` varchar(255) DEFAULT NULL,
  `stripe_charge_id` varchar(255) DEFAULT NULL,
  `stripe_invoice_id` varchar(255) DEFAULT NULL,
  `payment_method_id` varchar(255) DEFAULT NULL,
  `receipt_url` text DEFAULT NULL,
  `hosted_invoice_url` text DEFAULT NULL,
  `invoice_pdf_url` text DEFAULT NULL,
  `card_brand` varchar(50) DEFAULT NULL,
  `card_last4` varchar(10) DEFAULT NULL,
  `is_pending` tinyint(1) GENERATED ALWAYS AS (`status` = 'pending') STORED,
  PRIMARY KEY (`id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_expert` (`expert_id`),
  KEY `idx_status_created` (`status`,`created_at`),
  KEY `idx_service_orders_slot` (`slot_id`),
  KEY `idx_service_orders_payment_status` (`payment_status`),
  KEY `idx_service_orders_meeting_id` (`meeting_id`),
  KEY `idx_pending_lookup` (`user_id`,`expert_id`,`service_id`,`slot_id`,`status`),
  KEY `idx_so_meeting` (`meeting_id`,`created_at`),
  CONSTRAINT `service_orders_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `service_orders_ibfk_2` FOREIGN KEY (`expert_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=71 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `service_orders`
--

LOCK TABLES `service_orders` WRITE;
/*!40000 ALTER TABLE `service_orders` DISABLE KEYS */;
INSERT INTO `service_orders` VALUES
(1,3,3,1,19.99,'USD','pending',NULL,NULL,NULL,NULL,NULL,'2025-08-09 19:46:16','2025-08-19 13:03:15',NULL,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1),
(2,3,3,1,19.99,'USD','cancelled',NULL,NULL,NULL,'Please prepare documents before meeting',NULL,'2025-08-09 21:00:15','2025-08-15 05:44:16',NULL,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(3,3,3,1,19.99,'USD','pending',NULL,NULL,NULL,'Please review my resume before call',NULL,'2025-08-10 07:49:06','2025-08-12 07:39:13',NULL,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1),
(4,4,3,1,19.99,'USD','pending',NULL,NULL,NULL,'Please review my resume before call',NULL,'2025-08-11 15:28:11','2025-08-11 15:28:11',NULL,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1),
(5,4,3,1,19.99,'USD','paid',NULL,NULL,NULL,'Please review my resume before call','manual-OK-123','2025-08-11 19:18:52','2025-08-11 19:21:19',8,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(6,4,3,2,49.99,'USD','paid',NULL,NULL,NULL,NULL,'cs_test_b1LoAVIvITXyG6V25dVzM3umMBp52sogmnb03z0E4rTFOmR37d2FDXPbjU','2025-08-14 19:43:49','2025-08-14 19:44:31',30,'Paid',6,'pi_3Rw74X3RqEMUJuhk0anuzhlI','ch_3Rw74X3RqEMUJuhk01SLvTEy','in_1Rw74Z3RqEMUJuhkQLBAVt8v','pm_1Rw74W3RqEMUJuhkJyT3K4ug','https://pay.stripe.com/receipts/invoices/CAcaFwoVYWNjdF8xUnZ6bW0zUnFFTVVKdWhrKJ_5-MQGMgZICvWPGLU6LBYcH4C7KtuUlx8ao70PpsJsm_cqARnHUbhflXr_0R88izE56N_v7j_DoWpX?s=ap','https://invoice.stripe.com/i/acct_1Rvzmm3RqEMUJuhk/test_YWNjdF8xUnZ6bW0zUnFFTVVKdWhrLF9TcnFtellRZkRZN1BaRjUwbURoSXVrS2hzZXRvcWFxLDE0NTc0MTQ3MQ0200Lr0j6PZH?s=ap','https://pay.stripe.com/invoice/acct_1Rvzmm3RqEMUJuhk/test_YWNjdF8xUnZ6bW0zUnFFTVVKdWhrLF9TcnFtellRZkRZN1BaRjUwbURoSXVrS2hzZXRvcWFxLDE0NTc0MTQ3MQ0200Lr0j6PZH/pdf?s=ap','visa','4242',0),
(7,4,3,2,49.99,'USD','cancelled',NULL,NULL,NULL,NULL,NULL,'2025-08-14 20:50:02','2025-08-15 05:44:16',1,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(8,4,3,2,49.99,'USD','cancelled',NULL,NULL,NULL,NULL,NULL,'2025-08-14 20:50:02','2025-08-15 05:44:16',1,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(9,4,3,2,49.99,'USD','cancelled',NULL,NULL,NULL,NULL,NULL,'2025-08-14 20:54:03','2025-08-15 05:44:16',1,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(10,4,3,2,49.99,'USD','cancelled',NULL,NULL,NULL,NULL,NULL,'2025-08-14 20:54:03','2025-08-15 05:44:16',1,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(11,4,3,2,49.99,'USD','pending',NULL,NULL,NULL,NULL,NULL,'2025-08-14 20:58:04','2025-08-14 20:58:04',1,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1),
(12,4,3,1,19.99,'USD','cancelled',NULL,NULL,NULL,NULL,NULL,'2025-08-15 05:08:53','2025-08-15 05:44:16',32,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(13,4,3,1,19.99,'USD','cancelled',NULL,NULL,NULL,NULL,NULL,'2025-08-15 05:08:53','2025-08-15 05:44:16',32,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(14,4,3,1,19.99,'USD','cancelled',NULL,NULL,NULL,NULL,NULL,'2025-08-15 05:09:17','2025-08-15 05:44:16',32,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(15,4,3,1,19.99,'USD','cancelled',NULL,NULL,NULL,NULL,NULL,'2025-08-15 05:09:17','2025-08-15 05:44:16',32,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(16,4,3,1,19.99,'USD','cancelled',NULL,NULL,NULL,NULL,NULL,'2025-08-15 05:11:04','2025-08-15 05:44:16',32,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(17,4,3,1,19.99,'USD','cancelled',NULL,NULL,NULL,NULL,NULL,'2025-08-15 05:11:20','2025-08-15 05:44:16',32,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(18,4,3,1,19.99,'USD','cancelled',NULL,NULL,NULL,NULL,NULL,'2025-08-15 05:11:20','2025-08-15 05:44:16',32,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(19,4,3,1,19.99,'USD','cancelled',NULL,NULL,NULL,NULL,NULL,'2025-08-15 05:11:50','2025-08-15 05:44:16',32,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(20,4,3,1,19.99,'USD','cancelled',NULL,NULL,NULL,NULL,NULL,'2025-08-15 05:11:50','2025-08-15 05:44:16',32,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(21,4,3,1,19.99,'USD','cancelled',NULL,NULL,NULL,NULL,NULL,'2025-08-15 05:14:16','2025-08-15 05:44:16',32,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(22,4,3,1,19.99,'USD','cancelled',NULL,NULL,NULL,NULL,NULL,'2025-08-15 05:14:23','2025-08-15 05:44:16',32,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(23,4,3,1,19.99,'USD','cancelled',NULL,NULL,NULL,NULL,NULL,'2025-08-15 05:14:23','2025-08-15 05:44:16',32,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(24,4,3,1,19.99,'USD','cancelled',NULL,NULL,NULL,NULL,NULL,'2025-08-15 05:15:18','2025-08-15 05:44:16',32,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(25,4,3,1,19.99,'USD','cancelled',NULL,NULL,NULL,NULL,NULL,'2025-08-15 05:15:25','2025-08-15 05:44:16',32,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(26,4,3,1,19.99,'USD','cancelled',NULL,NULL,NULL,NULL,NULL,'2025-08-15 05:15:25','2025-08-15 05:44:16',32,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(27,4,3,1,19.99,'USD','cancelled',NULL,NULL,NULL,NULL,NULL,'2025-08-15 05:16:24','2025-08-15 05:44:16',32,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(28,4,3,1,19.99,'USD','cancelled',NULL,NULL,NULL,NULL,NULL,'2025-08-15 05:16:32','2025-08-15 05:44:16',32,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(29,4,3,1,19.99,'USD','cancelled',NULL,NULL,NULL,NULL,NULL,'2025-08-15 05:16:32','2025-08-15 05:44:16',32,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(30,4,3,1,19.99,'USD','cancelled',NULL,NULL,NULL,NULL,NULL,'2025-08-15 05:17:28','2025-08-15 05:44:16',32,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(31,4,3,1,19.99,'USD','cancelled',NULL,NULL,NULL,NULL,NULL,'2025-08-15 05:18:07','2025-08-15 05:44:16',32,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(32,4,3,1,19.99,'USD','cancelled',NULL,NULL,NULL,NULL,NULL,'2025-08-15 05:20:22','2025-08-15 05:44:16',32,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(33,4,3,1,19.99,'USD','cancelled',NULL,NULL,NULL,NULL,NULL,'2025-08-15 05:20:47','2025-08-15 05:44:16',32,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(34,4,3,1,19.99,'USD','cancelled',NULL,NULL,NULL,NULL,NULL,'2025-08-15 05:22:37','2025-08-15 05:44:16',32,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(35,4,3,1,19.99,'USD','cancelled',NULL,NULL,NULL,NULL,NULL,'2025-08-15 05:22:56','2025-08-15 05:44:16',32,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(36,4,3,1,19.99,'USD','paid',NULL,NULL,NULL,NULL,'cs_test_b1BjCsbtM1eKde8bGgWzwjnzaVuTdIUNIvtrHsqb1ixFs7fmwClld3JFm2','2025-08-15 05:23:11','2025-08-16 06:52:01',32,'Paid',7,'pi_3Rwdxw3RqEMUJuhk16iUcsFO','ch_3Rwdxw3RqEMUJuhk1skTjrTj','in_1Rwdxy3RqEMUJuhk8wFdoR26','pm_1Rw8v33RqEMUJuhkSAN3rnay','https://pay.stripe.com/receipts/invoices/CAcaFwoVYWNjdF8xUnZ6bW0zUnFFTVVKdWhrKJHVgMUGMgY-mXdTyFg6LBbUju_CRnKhkFVpdmSmtfDftvzB_cnmcOmRND5HAKuaeESvVH3AJyJutevz?s=ap','https://invoice.stripe.com/i/acct_1Rvzmm3RqEMUJuhk/test_YWNjdF8xUnZ6bW0zUnFFTVVKdWhrLF9Tc09sWkYwbFd6bHBRZGc1dHlJa0FhQzhxbkt2U3c2LDE0NTg2NzkyMQ0200PyLgYrV9?s=ap','https://pay.stripe.com/invoice/acct_1Rvzmm3RqEMUJuhk/test_YWNjdF8xUnZ6bW0zUnFFTVVKdWhrLF9Tc09sWkYwbFd6bHBRZGc1dHlJa0FhQzhxbkt2U3c2LDE0NTg2NzkyMQ0200PyLgYrV9/pdf?s=ap','visa','4242',0),
(37,4,3,1,19.99,'USD','pending',NULL,NULL,NULL,NULL,NULL,'2025-08-15 05:53:23','2025-08-15 05:53:23',1,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1),
(38,3,3,1,19.99,'USD','pending',NULL,NULL,NULL,NULL,NULL,'2025-08-15 10:41:09','2025-08-15 10:41:09',32,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1),
(39,3,3,1,19.99,'USD','paid',NULL,NULL,NULL,NULL,'cs_test_b1IfjVcKdWYKloyjDwmFJhkMU8PodwgYd5Z4xPVHctH1i39lbT587v0Z2p','2025-08-15 10:49:46','2025-08-16 07:40:17',33,'Paid',8,'pi_3Rweii3RqEMUJuhk1h6lUhVW','py_3Rweii3RqEMUJuhk10AMjbFM','in_1Rwein3RqEMUJuhkZXfYXxju','pm_1Rweih3RqEMUJuhk6S8OpnPk','https://pay.stripe.com/receipts/invoices/CAcaFwoVYWNjdF8xUnZ6bW0zUnFFTVVKdWhrKOHrgMUGMgYxprV3KCk6LBazZnimaArZJKcifiFYOWNGZzGCPFniVCKGn0dilPIHGQc1U0JlMlBoo8Ah?s=ap','https://invoice.stripe.com/i/acct_1Rvzmm3RqEMUJuhk/test_YWNjdF8xUnZ6bW0zUnFFTVVKdWhrLF9Tc1BYQ09rWlZsUDhhajRCTks0dzQyb2ZzTnV0U3FzLDE0NTg3MDgxNw0200aR5rRjxu?s=ap','https://pay.stripe.com/invoice/acct_1Rvzmm3RqEMUJuhk/test_YWNjdF8xUnZ6bW0zUnFFTVVKdWhrLF9Tc1BYQ09rWlZsUDhhajRCTks0dzQyb2ZzTnV0U3FzLDE0NTg3MDgxNw0200aR5rRjxu/pdf?s=ap',NULL,NULL,0),
(40,1,3,2,49.99,'USD','cancelled','2025-08-19 18:00:29',NULL,NULL,NULL,NULL,'2025-08-17 14:14:40','2025-08-19 12:00:29',25,'',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(41,5,3,5,10.00,'USD','paid',NULL,NULL,NULL,NULL,'cs_test_b1Shqp1eXsYWmqIH6jUbiivRrpfREcPwCkSKG67w7HXmJY98oe8qDHNxiS','2025-08-19 14:29:27','2025-08-19 14:29:59',25,'Paid',9,'pi_3RxqXu3RqEMUJuhk1oDIHDsE','ch_3RxqXu3RqEMUJuhk1yg0Bymq','in_1RxqXx3RqEMUJuhkiSq8kAJZ','pm_1RxqXt3RqEMUJuhkFNGx2BXH','https://pay.stripe.com/receipts/invoices/CAcaFwoVYWNjdF8xUnZ6bW0zUnFFTVVKdWhrKOeUksUGMgY0JGwVynQ6LBaZ0A4_dS77YzavX7_UKXW4vEC4EEWWnm6FKQ7zwrH_1yPnnHWQovX-SHdQ?s=ap','https://invoice.stripe.com/i/acct_1Rvzmm3RqEMUJuhk/test_YWNjdF8xUnZ6bW0zUnFFTVVKdWhrLF9TdGRwZXUxSEx3SUJhN3I4MEdic05uQm1maDVuQmRaLDE0NjE1NDU5OQ0200IubaNjyA?s=ap','https://pay.stripe.com/invoice/acct_1Rvzmm3RqEMUJuhk/test_YWNjdF8xUnZ6bW0zUnFFTVVKdWhrLF9TdGRwZXUxSEx3SUJhN3I4MEdic05uQm1maDVuQmRaLDE0NjE1NDU5OQ0200IubaNjyA/pdf?s=ap','visa','4242',0),
(42,1,3,5,10.00,'USD','pending',NULL,NULL,NULL,NULL,NULL,'2025-08-20 06:07:25','2025-08-20 06:07:25',36,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1),
(43,1,3,5,10.00,'USD','pending',NULL,NULL,NULL,NULL,NULL,'2025-08-20 06:07:25','2025-08-20 06:07:25',36,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1),
(44,3,3,6,450.00,'USD','pending',NULL,NULL,NULL,NULL,NULL,'2025-08-20 11:22:24','2025-08-20 11:22:24',37,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1),
(45,3,3,6,450.00,'USD','pending',NULL,NULL,NULL,NULL,NULL,'2025-08-20 11:22:24','2025-08-20 11:22:24',37,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1),
(46,2,3,5,10.00,'USD','pending',NULL,NULL,NULL,NULL,NULL,'2025-09-01 19:25:51','2025-09-01 19:25:51',130,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1),
(47,2,3,5,10.00,'USD','pending',NULL,NULL,NULL,NULL,NULL,'2025-09-01 19:25:51','2025-09-01 19:25:51',130,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1),
(48,2,3,4,30.00,'USD','pending',NULL,NULL,NULL,NULL,NULL,'2025-09-01 20:28:26','2025-09-01 20:28:26',130,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1),
(49,2,3,4,30.00,'USD','pending',NULL,NULL,NULL,NULL,NULL,'2025-09-01 20:28:26','2025-09-01 20:28:26',130,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1),
(50,2,3,1,19.99,'USD','paid',NULL,NULL,NULL,NULL,'pi_3S2eal3RqEMUJuhk05JzFYuQ','2025-09-01 20:44:40','2025-09-01 20:44:43',130,'Paid',10,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(51,3,3,5,10.00,'USD','pending',NULL,NULL,NULL,NULL,NULL,'2025-09-07 10:41:40','2025-09-07 10:41:40',112,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1),
(52,3,3,5,10.00,'USD','pending',NULL,NULL,NULL,NULL,NULL,'2025-09-07 10:41:40','2025-09-07 10:41:40',112,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1),
(53,2,3,5,10.00,'USD','paid',NULL,NULL,NULL,NULL,'pi_3S4g7u3RqEMUJuhk13boTqgn','2025-09-07 10:47:13','2025-09-07 10:47:18',112,'Paid',17,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0),
(54,2,3,5,10.00,'USD','pending',NULL,NULL,NULL,NULL,NULL,'2025-09-07 10:47:13','2025-09-07 10:47:13',112,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1),
(55,2,3,5,10.00,'USD','paid',NULL,NULL,NULL,NULL,NULL,'2025-09-07 12:16:28','2025-09-07 12:24:13',132,'Paid',18,NULL,NULL,NULL,NULL,NULL,'https://invoice.stripe.com/i/acct_1Rvzmm3RqEMUJuhk/test_YWNjdF8xUnZ6bW0zUnFFTVVKdWhrLF9UMGo1ZFREdlRoVkNVMEp4cjR3Qkd0aU1pR014SmVuLDE0Nzc4ODY1Mw0200yq5cuL4C?s=ap','https://pay.stripe.com/invoice/acct_1Rvzmm3RqEMUJuhk/test_YWNjdF8xUnZ6bW0zUnFFTVVKdWhrLF9UMGo1ZFREdlRoVkNVMEp4cjR3Qkd0aU1pR014SmVuLDE0Nzc4ODY1Mw0200yq5cuL4C/pdf?s=ap',NULL,NULL,0),
(56,2,3,3,29.00,'USD','paid',NULL,NULL,NULL,NULL,NULL,'2025-09-07 13:49:29','2025-09-07 14:50:26',133,'Paid',19,NULL,NULL,NULL,NULL,'https://pay.stripe.com/receipts/payment/CAcaFwoVYWNjdF8xUnZ6bW0zUnFFTVVKdWhrKLK39sUGMgaLFy8s8nw6LBZtQj0Dskh23fbexHCo79c8VvT3Fu17_ajFyS_9lxpwQPlhGa2b1iVGWHWg',NULL,NULL,'visa','4242',0),
(57,9,3,4,30.00,'USD','pending',NULL,NULL,NULL,NULL,NULL,'2025-09-13 07:47:26','2025-09-13 07:47:26',114,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1),
(58,13,3,5,10.00,'USD','paid',NULL,NULL,NULL,NULL,NULL,'2025-09-13 08:03:36','2025-09-13 08:03:53',114,'Paid',20,NULL,NULL,NULL,NULL,NULL,'https://invoice.stripe.com/i/acct_1Rvzmm3RqEMUJuhk/test_YWNjdF8xUnZ6bW0zUnFFTVVKdWhrLF9UMnVGMFZla2pvRWU2azMxSXVRRDIySG1BWjFmNlByLDE0ODI5MTQyNA0200RH2sc8FY?s=ap','https://pay.stripe.com/invoice/acct_1Rvzmm3RqEMUJuhk/test_YWNjdF8xUnZ6bW0zUnFFTVVKdWhrLF9UMnVGMFZla2pvRWU2azMxSXVRRDIySG1BWjFmNlByLDE0ODI5MTQyNA0200RH2sc8FY/pdf?s=ap',NULL,NULL,0),
(59,2,6,7,125.00,'USD','paid',NULL,NULL,NULL,NULL,NULL,'2025-09-14 07:24:52','2025-09-14 07:25:22',199,'Paid',21,NULL,NULL,NULL,NULL,NULL,'https://invoice.stripe.com/i/acct_1Rvzmm3RqEMUJuhk/test_YWNjdF8xUnZ6bW0zUnFFTVVKdWhrLF9UM0dxUkVZVXp1SUMwZlhZY2dKTTJiOEZoSnF2OHY5LDE0ODM3NTQ5OA02001hIj3vTU?s=ap','https://pay.stripe.com/invoice/acct_1Rvzmm3RqEMUJuhk/test_YWNjdF8xUnZ6bW0zUnFFTVVKdWhrLF9UM0dxUkVZVXp1SUMwZlhZY2dKTTJiOEZoSnF2OHY5LDE0ODM3NTQ5OA02001hIj3vTU/pdf?s=ap',NULL,NULL,0),
(60,2,6,7,125.00,'USD','paid',NULL,NULL,NULL,NULL,NULL,'2025-09-14 07:37:53','2025-09-14 07:38:06',198,'Paid',22,NULL,NULL,NULL,NULL,NULL,'https://invoice.stripe.com/i/acct_1Rvzmm3RqEMUJuhk/test_YWNjdF8xUnZ6bW0zUnFFTVVKdWhrLF9UM0gzclhxMnhnM1RpYzlKa3NZZVJqM1F3RTF1OWJLLDE0ODM3NjI3Nw0200QJtYk6EI?s=ap','https://pay.stripe.com/invoice/acct_1Rvzmm3RqEMUJuhk/test_YWNjdF8xUnZ6bW0zUnFFTVVKdWhrLF9UM0gzclhxMnhnM1RpYzlKa3NZZVJqM1F3RTF1OWJLLDE0ODM3NjI3Nw0200QJtYk6EI/pdf?s=ap',NULL,NULL,0),
(61,3,6,7,125.00,'USD','pending',NULL,NULL,NULL,NULL,NULL,'2025-09-25 10:02:26','2025-09-25 10:02:26',206,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1),
(62,3,3,6,450.00,'USD','pending',NULL,NULL,NULL,NULL,NULL,'2025-09-25 10:03:55','2025-09-25 10:03:55',162,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1),
(63,4,3,8,500.00,'USD','paid',NULL,NULL,NULL,NULL,NULL,'2025-09-27 09:21:15','2025-09-27 09:21:29',121,'Paid',23,NULL,NULL,NULL,NULL,NULL,'https://invoice.stripe.com/i/acct_1Rvzmm3RqEMUJuhk/test_YWNjdF8xUnZ6bW0zUnFFTVVKdWhrLF9UOEFlcGx3TVQ2MEtBUG5BWjFmQzNYZ2VXMjBIV21xLDE0OTUwNTY4MA02007HL9g6ji?s=ap','https://pay.stripe.com/invoice/acct_1Rvzmm3RqEMUJuhk/test_YWNjdF8xUnZ6bW0zUnFFTVVKdWhrLF9UOEFlcGx3TVQ2MEtBUG5BWjFmQzNYZ2VXMjBIV21xLDE0OTUwNTY4MA02007HL9g6ji/pdf?s=ap',NULL,NULL,0),
(64,3,6,7,125.00,'USD','pending',NULL,NULL,NULL,NULL,NULL,'2025-09-27 09:28:34','2025-09-27 09:28:34',200,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1),
(65,3,6,7,125.00,'USD','pending',NULL,NULL,NULL,NULL,NULL,'2025-09-28 10:08:22','2025-09-28 10:08:22',203,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1),
(66,6,6,7,0.01,'USD','pending',NULL,NULL,NULL,NULL,NULL,'2025-09-28 18:18:18','2025-09-28 18:18:18',300,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1),
(67,17,6,7,3.00,'USD','paid',NULL,NULL,NULL,NULL,'pi_3SCPDs3RqEMUJuhk00X6Qr4K','2025-09-28 18:19:56','2025-09-28 18:28:22',300,'Paid',24,'pi_3SCPDs3RqEMUJuhk00X6Qr4K',NULL,NULL,NULL,'https://pay.stripe.com/receipts/payment/CAcaFwoVYWNjdF8xUnZ6bW0zUnFFTVVKdWhrKMb85cYGMgYcRu0btx06LBbhDwMU-pFOCdHxBno2LxvnLYGI4RqHXno8OHpWrckaNcQ5gSzIZZeTybs3',NULL,NULL,NULL,NULL,0),
(68,16,6,7,3.00,'USD','paid',NULL,NULL,NULL,NULL,'pi_3SCPRO3RqEMUJuhk0CEZO5qc','2025-09-28 18:34:11','2025-09-28 18:37:40',301,'Paid',25,'pi_3SCPRO3RqEMUJuhk0CEZO5qc',NULL,NULL,NULL,'https://pay.stripe.com/receipts/payment/CAcaFwoVYWNjdF8xUnZ6bW0zUnFFTVVKdWhrKPSA5sYGMgbv-Uc1x9I6LBZuc1YrH5B3NPMohNeKOC5vFdKgeRjs66E18nI2NyRbz29GxBD-sMrTxSj2',NULL,NULL,NULL,NULL,0),
(69,6,6,7,3.00,'USD','pending',NULL,NULL,NULL,NULL,NULL,'2025-10-05 15:30:24','2025-10-05 15:30:24',312,'Pending',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1),
(70,15,6,7,3.00,'USD','paid',NULL,NULL,NULL,NULL,'pi_3SEunM3RqEMUJuhk19pRMy1l','2025-10-05 16:26:21','2025-10-05 16:28:28',303,'Paid',27,'pi_3SEunM3RqEMUJuhk19pRMy1l',NULL,NULL,NULL,'https://pay.stripe.com/receipts/payment/CAcaFwoVYWNjdF8xUnZ6bW0zUnFFTVVKdWhrKKy5iscGMgZZLSPaXoM6LBYVRoJKPtDfyZ4GR2rU4W45DJGa1X2MU64kh2V24RLRFlqiLXwRvRpIhadh',NULL,NULL,NULL,NULL,0);
/*!40000 ALTER TABLE `service_orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `service_reviews`
--

DROP TABLE IF EXISTS `service_reviews`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `service_reviews` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `service_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `rating` int(11) DEFAULT NULL CHECK (`rating` between 1 and 5),
  `review` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_review` (`service_id`,`user_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `service_reviews_ibfk_1` FOREIGN KEY (`service_id`) REFERENCES `expert_services` (`id`),
  CONSTRAINT `service_reviews_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `service_reviews`
--

LOCK TABLES `service_reviews` WRITE;
/*!40000 ALTER TABLE `service_reviews` DISABLE KEYS */;
INSERT INTO `service_reviews` VALUES
(1,1,3,4,'Very helpful session!','2025-08-05 19:44:44');
/*!40000 ALTER TABLE `service_reviews` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `skills`
--

DROP TABLE IF EXISTS `skills`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `skills` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `skills`
--

LOCK TABLES `skills` WRITE;
/*!40000 ALTER TABLE `skills` DISABLE KEYS */;
INSERT INTO `skills` VALUES
(3,'AI Strategy'),
(10,'Building Innovation Ecosystems'),
(8,'Change Management'),
(12,'Design and System Thinking'),
(9,'Entrepreneurship and Startups Development'),
(7,'Innovation Management and Leadership'),
(11,'Leadership Coaching and Advisory Services'),
(4,'NodeJS'),
(1,'Python'),
(5,'ReactJs'),
(6,'RwactJS'),
(13,'Social Impact and Social Innovation'),
(2,'TensorFlow');
/*!40000 ALTER TABLE `skills` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `stripe_balance_txns`
--

DROP TABLE IF EXISTS `stripe_balance_txns`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `stripe_balance_txns` (
  `id` varchar(64) NOT NULL,
  `amount` bigint(20) NOT NULL,
  `currency` char(3) NOT NULL,
  `fee` bigint(20) NOT NULL,
  `net` bigint(20) NOT NULL,
  `type` varchar(64) NOT NULL,
  `reporting_category` varchar(64) DEFAULT NULL,
  `source_id` varchar(64) DEFAULT NULL,
  `created` int(11) NOT NULL,
  `available_on` int(11) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `raw` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`raw`)),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stripe_balance_txns`
--

LOCK TABLES `stripe_balance_txns` WRITE;
/*!40000 ALTER TABLE `stripe_balance_txns` DISABLE KEYS */;
INSERT INTO `stripe_balance_txns` VALUES
('txn_3Rw0Fo3RqEMUJuhk1zqhNL0t',2700,'CAD',130,2570,'charge','charge','ch_3Rw0Fo3RqEMUJuhk1gG6UEw2',1755174456,1755734400,NULL,'{\"id\":\"txn_3Rw0Fo3RqEMUJuhk1zqhNL0t\",\"object\":\"balance_transaction\",\"amount\":2700,\"available_on\":1755734400,\"balance_type\":\"payments\",\"created\":1755174456,\"currency\":\"cad\",\"description\":null,\"exchange_rate\":1.3507,\"fee\":130,\"fee_details\":[{\"amount\":130,\"application\":null,\"currency\":\"cad\",\"description\":\"Stripe processing fees\",\"type\":\"stripe_fee\"}],\"net\":2570,\"reporting_category\":\"charge\",\"source\":\"ch_3Rw0Fo3RqEMUJuhk1gG6UEw2\",\"status\":\"available\",\"type\":\"charge\"}','2025-09-09 19:50:39'),
('txn_3Rw12w3RqEMUJuhk1JF2mbXv',2703,'CAD',130,2573,'charge','charge','ch_3Rw12w3RqEMUJuhk154ArQgv',1755177503,1755734400,NULL,'{\"id\":\"txn_3Rw12w3RqEMUJuhk1JF2mbXv\",\"object\":\"balance_transaction\",\"amount\":2703,\"available_on\":1755734400,\"balance_type\":\"payments\",\"created\":1755177503,\"currency\":\"cad\",\"description\":null,\"exchange_rate\":1.35205,\"fee\":130,\"fee_details\":[{\"amount\":130,\"application\":null,\"currency\":\"cad\",\"description\":\"Stripe processing fees\",\"type\":\"stripe_fee\"}],\"net\":2573,\"reporting_category\":\"charge\",\"source\":\"ch_3Rw12w3RqEMUJuhk154ArQgv\",\"status\":\"available\",\"type\":\"charge\"}','2025-09-09 19:50:39'),
('txn_3Rw1lV3RqEMUJuhk0auEOR0Y',2705,'CAD',130,2575,'charge','charge','ch_3Rw1lV3RqEMUJuhk0IqNwYlx',1755180266,1755734400,NULL,'{\"id\":\"txn_3Rw1lV3RqEMUJuhk0auEOR0Y\",\"object\":\"balance_transaction\",\"amount\":2705,\"available_on\":1755734400,\"balance_type\":\"payments\",\"created\":1755180266,\"currency\":\"cad\",\"description\":null,\"exchange_rate\":1.35332,\"fee\":130,\"fee_details\":[{\"amount\":130,\"application\":null,\"currency\":\"cad\",\"description\":\"Stripe processing fees\",\"type\":\"stripe_fee\"}],\"net\":2575,\"reporting_category\":\"charge\",\"source\":\"ch_3Rw1lV3RqEMUJuhk0IqNwYlx\",\"status\":\"available\",\"type\":\"charge\"}','2025-09-09 19:50:39'),
('txn_3Rw1R03RqEMUJuhk1WY4chPZ',2703,'CAD',130,2573,'charge','charge','ch_3Rw1R03RqEMUJuhk1PSlV2rJ',1755178994,1755734400,NULL,'{\"id\":\"txn_3Rw1R03RqEMUJuhk1WY4chPZ\",\"object\":\"balance_transaction\",\"amount\":2703,\"available_on\":1755734400,\"balance_type\":\"payments\",\"created\":1755178994,\"currency\":\"cad\",\"description\":null,\"exchange_rate\":1.35205,\"fee\":130,\"fee_details\":[{\"amount\":130,\"application\":null,\"currency\":\"cad\",\"description\":\"Stripe processing fees\",\"type\":\"stripe_fee\"}],\"net\":2573,\"reporting_category\":\"charge\",\"source\":\"ch_3Rw1R03RqEMUJuhk1PSlV2rJ\",\"status\":\"available\",\"type\":\"charge\"}','2025-09-09 19:50:39'),
('txn_3Rw1rQ3RqEMUJuhk1KOnFdG2',2705,'CAD',130,2575,'charge','charge','ch_3Rw1rQ3RqEMUJuhk1YD8TUR0',1755180633,1755734400,NULL,'{\"id\":\"txn_3Rw1rQ3RqEMUJuhk1KOnFdG2\",\"object\":\"balance_transaction\",\"amount\":2705,\"available_on\":1755734400,\"balance_type\":\"payments\",\"created\":1755180633,\"currency\":\"cad\",\"description\":null,\"exchange_rate\":1.35332,\"fee\":130,\"fee_details\":[{\"amount\":130,\"application\":null,\"currency\":\"cad\",\"description\":\"Stripe processing fees\",\"type\":\"stripe_fee\"}],\"net\":2575,\"reporting_category\":\"charge\",\"source\":\"ch_3Rw1rQ3RqEMUJuhk1YD8TUR0\",\"status\":\"available\",\"type\":\"charge\"}','2025-09-09 19:50:39'),
('txn_3Rw23E3RqEMUJuhk0AeRfyML',2705,'CAD',130,2575,'charge','charge','ch_3Rw23E3RqEMUJuhk0Sx483pP',1755181364,1755734400,NULL,'{\"id\":\"txn_3Rw23E3RqEMUJuhk0AeRfyML\",\"object\":\"balance_transaction\",\"amount\":2705,\"available_on\":1755734400,\"balance_type\":\"payments\",\"created\":1755181364,\"currency\":\"cad\",\"description\":null,\"exchange_rate\":1.35332,\"fee\":130,\"fee_details\":[{\"amount\":130,\"application\":null,\"currency\":\"cad\",\"description\":\"Stripe processing fees\",\"type\":\"stripe_fee\"}],\"net\":2575,\"reporting_category\":\"charge\",\"source\":\"ch_3Rw23E3RqEMUJuhk0Sx483pP\",\"status\":\"available\",\"type\":\"charge\"}','2025-09-09 19:50:39'),
('txn_3Rw2Fx3RqEMUJuhk1Dy3hQTX',2705,'CAD',130,2575,'charge','charge','ch_3Rw2Fx3RqEMUJuhk1OHU26Th',1755182154,1755734400,NULL,'{\"id\":\"txn_3Rw2Fx3RqEMUJuhk1Dy3hQTX\",\"object\":\"balance_transaction\",\"amount\":2705,\"available_on\":1755734400,\"balance_type\":\"payments\",\"created\":1755182154,\"currency\":\"cad\",\"description\":null,\"exchange_rate\":1.35332,\"fee\":130,\"fee_details\":[{\"amount\":130,\"application\":null,\"currency\":\"cad\",\"description\":\"Stripe processing fees\",\"type\":\"stripe_fee\"}],\"net\":2575,\"reporting_category\":\"charge\",\"source\":\"ch_3Rw2Fx3RqEMUJuhk1OHU26Th\",\"status\":\"available\",\"type\":\"charge\"}','2025-09-09 19:50:39'),
('txn_3Rw5fg3RqEMUJuhk0mzRB6Ai',6767,'CAD',280,6487,'charge','charge','ch_3Rw5fg3RqEMUJuhk0VJKWn1Y',1755195281,1755734400,NULL,'{\"id\":\"txn_3Rw5fg3RqEMUJuhk0mzRB6Ai\",\"object\":\"balance_transaction\",\"amount\":6767,\"available_on\":1755734400,\"balance_type\":\"payments\",\"created\":1755195281,\"currency\":\"cad\",\"description\":null,\"exchange_rate\":1.35365,\"fee\":280,\"fee_details\":[{\"amount\":280,\"application\":null,\"currency\":\"cad\",\"description\":\"Stripe processing fees\",\"type\":\"stripe_fee\"}],\"net\":6487,\"reporting_category\":\"charge\",\"source\":\"ch_3Rw5fg3RqEMUJuhk0VJKWn1Y\",\"status\":\"available\",\"type\":\"charge\"}','2025-09-09 19:50:39'),
('txn_3Rw74X3RqEMUJuhk0bDgGDFm',6768,'CAD',280,6488,'charge','charge','ch_3Rw74X3RqEMUJuhk01SLvTEy',1755200665,1755734400,'Order #6','{\"id\":\"txn_3Rw74X3RqEMUJuhk0bDgGDFm\",\"object\":\"balance_transaction\",\"amount\":6768,\"available_on\":1755734400,\"balance_type\":\"payments\",\"created\":1755200665,\"currency\":\"cad\",\"description\":\"Order #6\",\"exchange_rate\":1.35385,\"fee\":280,\"fee_details\":[{\"amount\":280,\"application\":null,\"currency\":\"cad\",\"description\":\"Stripe processing fees\",\"type\":\"stripe_fee\"}],\"net\":6488,\"reporting_category\":\"charge\",\"source\":\"ch_3Rw74X3RqEMUJuhk01SLvTEy\",\"status\":\"available\",\"type\":\"charge\"}','2025-09-09 19:50:39'),
('txn_3Rwdxw3RqEMUJuhk16V8yYQr',2708,'CAD',130,2578,'charge','charge','ch_3Rwdxw3RqEMUJuhk1skTjrTj',1755327108,1755907200,'Order #36','{\"id\":\"txn_3Rwdxw3RqEMUJuhk16V8yYQr\",\"object\":\"balance_transaction\",\"amount\":2708,\"available_on\":1755907200,\"balance_type\":\"payments\",\"created\":1755327108,\"currency\":\"cad\",\"description\":\"Order #36\",\"exchange_rate\":1.35444,\"fee\":130,\"fee_details\":[{\"amount\":130,\"application\":null,\"currency\":\"cad\",\"description\":\"Stripe processing fees\",\"type\":\"stripe_fee\"}],\"net\":2578,\"reporting_category\":\"charge\",\"source\":\"ch_3Rwdxw3RqEMUJuhk1skTjrTj\",\"status\":\"available\",\"type\":\"charge\"}','2025-09-09 19:50:39'),
('txn_3Rweii3RqEMUJuhk1JqeT3Zp',2708,'CAD',130,2578,'payment','charge','py_3Rweii3RqEMUJuhk10AMjbFM',1755330011,1755907200,'Order #39','{\"id\":\"txn_3Rweii3RqEMUJuhk1JqeT3Zp\",\"object\":\"balance_transaction\",\"amount\":2708,\"available_on\":1755907200,\"balance_type\":\"payments\",\"created\":1755330011,\"currency\":\"cad\",\"description\":\"Order #39\",\"exchange_rate\":1.35444,\"fee\":130,\"fee_details\":[{\"amount\":130,\"application\":null,\"currency\":\"cad\",\"description\":\"Stripe processing fees\",\"type\":\"stripe_fee\"}],\"net\":2578,\"reporting_category\":\"charge\",\"source\":\"py_3Rweii3RqEMUJuhk10AMjbFM\",\"status\":\"available\",\"type\":\"payment\"}','2025-09-09 19:50:39'),
('txn_3RwlFW3RqEMUJuhk1Kjmi7J0',3928,'CAD',175,3753,'charge','charge','ch_3RwlFW3RqEMUJuhk1YTz6rTA',1755355107,1755907200,'Order #41','{\"id\":\"txn_3RwlFW3RqEMUJuhk1Kjmi7J0\",\"object\":\"balance_transaction\",\"amount\":3928,\"available_on\":1755907200,\"balance_type\":\"payments\",\"created\":1755355107,\"currency\":\"cad\",\"description\":\"Order #41\",\"exchange_rate\":1.35439,\"fee\":175,\"fee_details\":[{\"amount\":175,\"application\":null,\"currency\":\"cad\",\"description\":\"Stripe processing fees\",\"type\":\"stripe_fee\"}],\"net\":3753,\"reporting_category\":\"charge\",\"source\":\"ch_3RwlFW3RqEMUJuhk1YTz6rTA\",\"status\":\"available\",\"type\":\"charge\"}','2025-09-09 19:50:39'),
('txn_3RwoVJ3RqEMUJuhk0F2Kk407',2709,'CAD',130,2579,'charge','charge','ch_3RwoVJ3RqEMUJuhk0U5h3L06',1755367617,1755907200,NULL,'{\"id\":\"txn_3RwoVJ3RqEMUJuhk0F2Kk407\",\"object\":\"balance_transaction\",\"amount\":2709,\"available_on\":1755907200,\"balance_type\":\"payments\",\"created\":1755367617,\"currency\":\"cad\",\"description\":null,\"exchange_rate\":1.35444,\"fee\":130,\"fee_details\":[{\"amount\":130,\"application\":null,\"currency\":\"cad\",\"description\":\"Stripe processing fees\",\"type\":\"stripe_fee\"}],\"net\":2579,\"reporting_category\":\"charge\",\"source\":\"ch_3RwoVJ3RqEMUJuhk0U5h3L06\",\"status\":\"available\",\"type\":\"charge\"}','2025-09-09 19:50:39'),
('txn_3RwpAf3RqEMUJuhk0Glh1Ds9',2709,'CAD',130,2579,'charge','charge','ch_3RwpAf3RqEMUJuhk0qL72Jpw',1755370181,1755907200,NULL,'{\"id\":\"txn_3RwpAf3RqEMUJuhk0Glh1Ds9\",\"object\":\"balance_transaction\",\"amount\":2709,\"available_on\":1755907200,\"balance_type\":\"payments\",\"created\":1755370181,\"currency\":\"cad\",\"description\":null,\"exchange_rate\":1.35444,\"fee\":130,\"fee_details\":[{\"amount\":130,\"application\":null,\"currency\":\"cad\",\"description\":\"Stripe processing fees\",\"type\":\"stripe_fee\"}],\"net\":2579,\"reporting_category\":\"charge\",\"source\":\"ch_3RwpAf3RqEMUJuhk0qL72Jpw\",\"status\":\"available\",\"type\":\"charge\"}','2025-09-09 19:50:39'),
('txn_3Rwxpm3RqEMUJuhk042Wdirj',2708,'CAD',130,2578,'charge','charge','ch_3Rwxpm3RqEMUJuhk0lJLuCJy',1755403482,1755993600,'Order #1','{\"id\":\"txn_3Rwxpm3RqEMUJuhk042Wdirj\",\"object\":\"balance_transaction\",\"amount\":2708,\"available_on\":1755993600,\"balance_type\":\"payments\",\"created\":1755403482,\"currency\":\"cad\",\"description\":\"Order #1\",\"exchange_rate\":1.35444,\"fee\":130,\"fee_details\":[{\"amount\":130,\"application\":null,\"currency\":\"cad\",\"description\":\"Stripe processing fees\",\"type\":\"stripe_fee\"}],\"net\":2578,\"reporting_category\":\"charge\",\"source\":\"ch_3Rwxpm3RqEMUJuhk0lJLuCJy\",\"status\":\"available\",\"type\":\"charge\"}','2025-09-09 19:50:39'),
('txn_3Rx7N83RqEMUJuhk1lvTbWor',6771,'CAD',281,6490,'charge','charge','ch_3Rx7N83RqEMUJuhk1cQeB3VQ',1755440147,1755993600,'Order #40','{\"id\":\"txn_3Rx7N83RqEMUJuhk1lvTbWor\",\"object\":\"balance_transaction\",\"amount\":6771,\"available_on\":1755993600,\"balance_type\":\"payments\",\"created\":1755440147,\"currency\":\"cad\",\"description\":\"Order #40\",\"exchange_rate\":1.35444,\"fee\":281,\"fee_details\":[{\"amount\":281,\"application\":null,\"currency\":\"cad\",\"description\":\"Stripe processing fees\",\"type\":\"stripe_fee\"}],\"net\":6490,\"reporting_category\":\"charge\",\"source\":\"ch_3Rx7N83RqEMUJuhk1cQeB3VQ\",\"status\":\"available\",\"type\":\"charge\"}','2025-09-09 19:50:39'),
('txn_3Rx7Xt3RqEMUJuhk0HpPtkcM',6771,'CAD',281,6490,'charge','charge','ch_3Rx7Xt3RqEMUJuhk0AJBHRbT',1755440813,1755993600,'Order #40','{\"id\":\"txn_3Rx7Xt3RqEMUJuhk0HpPtkcM\",\"object\":\"balance_transaction\",\"amount\":6771,\"available_on\":1755993600,\"balance_type\":\"payments\",\"created\":1755440813,\"currency\":\"cad\",\"description\":\"Order #40\",\"exchange_rate\":1.35444,\"fee\":281,\"fee_details\":[{\"amount\":281,\"application\":null,\"currency\":\"cad\",\"description\":\"Stripe processing fees\",\"type\":\"stripe_fee\"}],\"net\":6490,\"reporting_category\":\"charge\",\"source\":\"ch_3Rx7Xt3RqEMUJuhk0AJBHRbT\",\"status\":\"available\",\"type\":\"charge\"}','2025-09-09 19:50:39'),
('txn_3RxmEB3RqEMUJuhk0JPIvzFO',2707,'CAD',130,2577,'charge','charge','ch_3RxmEB3RqEMUJuhk0sApluJz',1755597196,1756166400,'Order #37','{\"id\":\"txn_3RxmEB3RqEMUJuhk0JPIvzFO\",\"object\":\"balance_transaction\",\"amount\":2707,\"available_on\":1756166400,\"balance_type\":\"payments\",\"created\":1755597196,\"currency\":\"cad\",\"description\":\"Order #37\",\"exchange_rate\":1.35421,\"fee\":130,\"fee_details\":[{\"amount\":130,\"application\":null,\"currency\":\"cad\",\"description\":\"Stripe processing fees\",\"type\":\"stripe_fee\"}],\"net\":2577,\"reporting_category\":\"charge\",\"source\":\"ch_3RxmEB3RqEMUJuhk0sApluJz\",\"status\":\"available\",\"type\":\"charge\"}','2025-09-09 19:50:39'),
('txn_3RxqXu3RqEMUJuhk1VBPl90k',1356,'CAD',80,1276,'charge','charge','ch_3RxqXu3RqEMUJuhk1yg0Bymq',1755613795,1756166400,'Order #41','{\"id\":\"txn_3RxqXu3RqEMUJuhk1VBPl90k\",\"object\":\"balance_transaction\",\"amount\":1356,\"available_on\":1756166400,\"balance_type\":\"payments\",\"created\":1755613795,\"currency\":\"cad\",\"description\":\"Order #41\",\"exchange_rate\":1.35648,\"fee\":80,\"fee_details\":[{\"amount\":80,\"application\":null,\"currency\":\"cad\",\"description\":\"Stripe processing fees\",\"type\":\"stripe_fee\"}],\"net\":1276,\"reporting_category\":\"charge\",\"source\":\"ch_3RxqXu3RqEMUJuhk1yg0Bymq\",\"status\":\"available\",\"type\":\"charge\"}','2025-09-09 19:50:39'),
('txn_3RzAd43RqEMUJuhk0xHWNct0',2708,'CAD',130,2578,'charge','charge','ch_3RzAd43RqEMUJuhk0hHooNl2',1755929322,1756512000,'Order #37','{\"id\":\"txn_3RzAd43RqEMUJuhk0xHWNct0\",\"object\":\"balance_transaction\",\"amount\":2708,\"available_on\":1756512000,\"balance_type\":\"payments\",\"created\":1755929322,\"currency\":\"cad\",\"description\":\"Order #37\",\"exchange_rate\":1.35477,\"fee\":130,\"fee_details\":[{\"amount\":130,\"application\":null,\"currency\":\"cad\",\"description\":\"Stripe processing fees\",\"type\":\"stripe_fee\"}],\"net\":2578,\"reporting_category\":\"charge\",\"source\":\"ch_3RzAd43RqEMUJuhk0hHooNl2\",\"status\":\"available\",\"type\":\"charge\"}','2025-09-09 19:50:39'),
('txn_3RzAwn3RqEMUJuhk0gtaGzVW',2710,'CAD',130,2580,'charge','charge','ch_3RzAwn3RqEMUJuhk0NWgDpq1',1755930546,1756512000,NULL,'{\"id\":\"txn_3RzAwn3RqEMUJuhk0gtaGzVW\",\"object\":\"balance_transaction\",\"amount\":2710,\"available_on\":1756512000,\"balance_type\":\"payments\",\"created\":1755930546,\"currency\":\"cad\",\"description\":null,\"exchange_rate\":1.35477,\"fee\":130,\"fee_details\":[{\"amount\":130,\"application\":null,\"currency\":\"cad\",\"description\":\"Stripe processing fees\",\"type\":\"stripe_fee\"}],\"net\":2580,\"reporting_category\":\"charge\",\"source\":\"ch_3RzAwn3RqEMUJuhk0NWgDpq1\",\"status\":\"available\",\"type\":\"charge\"}','2025-09-09 19:50:39'),
('txn_3RzAxN3RqEMUJuhk1qWFbwLk',6638,'CAD',276,6362,'charge','charge','ch_3RzAxN3RqEMUJuhk1xUGT4hG',1755930582,1756512000,NULL,'{\"id\":\"txn_3RzAxN3RqEMUJuhk1qWFbwLk\",\"object\":\"balance_transaction\",\"amount\":6638,\"available_on\":1756512000,\"balance_type\":\"payments\",\"created\":1755930582,\"currency\":\"cad\",\"description\":null,\"exchange_rate\":1.35477,\"fee\":276,\"fee_details\":[{\"amount\":276,\"application\":null,\"currency\":\"cad\",\"description\":\"Stripe processing fees\",\"type\":\"stripe_fee\"}],\"net\":6362,\"reporting_category\":\"charge\",\"source\":\"ch_3RzAxN3RqEMUJuhk1xUGT4hG\",\"status\":\"available\",\"type\":\"charge\"}','2025-09-09 19:50:39'),
('txn_3RzaYP3RqEMUJuhk16JVwthh',2710,'CAD',130,2580,'charge','charge','ch_3RzaYP3RqEMUJuhk14fqczKc',1756028978,1756598400,'Coaching order #8','{\"id\":\"txn_3RzaYP3RqEMUJuhk16JVwthh\",\"object\":\"balance_transaction\",\"amount\":2710,\"available_on\":1756598400,\"balance_type\":\"payments\",\"created\":1756028978,\"currency\":\"cad\",\"description\":\"Coaching order #8\",\"exchange_rate\":1.35477,\"fee\":130,\"fee_details\":[{\"amount\":130,\"application\":null,\"currency\":\"cad\",\"description\":\"Stripe processing fees\",\"type\":\"stripe_fee\"}],\"net\":2580,\"reporting_category\":\"charge\",\"source\":\"ch_3RzaYP3RqEMUJuhk14fqczKc\",\"status\":\"available\",\"type\":\"charge\"}','2025-09-09 19:50:39'),
('txn_3RzZjD3RqEMUJuhk16JujOHN',2711,'CAD',130,2581,'charge','charge','ch_3RzZjD3RqEMUJuhk1Exu1DKs',1756025803,1756598400,NULL,'{\"id\":\"txn_3RzZjD3RqEMUJuhk16JujOHN\",\"object\":\"balance_transaction\",\"amount\":2711,\"available_on\":1756598400,\"balance_type\":\"payments\",\"created\":1756025803,\"currency\":\"cad\",\"description\":null,\"exchange_rate\":1.35532,\"fee\":130,\"fee_details\":[{\"amount\":130,\"application\":null,\"currency\":\"cad\",\"description\":\"Stripe processing fees\",\"type\":\"stripe_fee\"}],\"net\":2581,\"reporting_category\":\"charge\",\"source\":\"ch_3RzZjD3RqEMUJuhk1Exu1DKs\",\"status\":\"available\",\"type\":\"charge\"}','2025-09-09 19:50:39'),
('txn_3S0Mxh3RqEMUJuhk1mVoIuWd',25781,'CAD',984,24797,'charge','charge','ch_3S0Mxh3RqEMUJuhk1A23N6Px',1756215057,1756771200,NULL,'{\"id\":\"txn_3S0Mxh3RqEMUJuhk1mVoIuWd\",\"object\":\"balance_transaction\",\"amount\":25781,\"available_on\":1756771200,\"balance_type\":\"payments\",\"created\":1756215057,\"currency\":\"cad\",\"description\":null,\"exchange_rate\":1.35688,\"fee\":984,\"fee_details\":[{\"amount\":984,\"application\":null,\"currency\":\"cad\",\"description\":\"Stripe processing fees\",\"type\":\"stripe_fee\"}],\"net\":24797,\"reporting_category\":\"charge\",\"source\":\"ch_3S0Mxh3RqEMUJuhk1A23N6Px\",\"status\":\"available\",\"type\":\"charge\"}','2025-09-09 19:50:39'),
('txn_3S0Myh3RqEMUJuhk1kF6JMWt',25781,'CAD',984,24797,'payment','charge','py_3S0Myh3RqEMUJuhk1YOqHu7u',1756215135,1756771200,NULL,'{\"id\":\"txn_3S0Myh3RqEMUJuhk1kF6JMWt\",\"object\":\"balance_transaction\",\"amount\":25781,\"available_on\":1756771200,\"balance_type\":\"payments\",\"created\":1756215135,\"currency\":\"cad\",\"description\":null,\"exchange_rate\":1.35688,\"fee\":984,\"fee_details\":[{\"amount\":984,\"application\":null,\"currency\":\"cad\",\"description\":\"Stripe processing fees\",\"type\":\"stripe_fee\"}],\"net\":24797,\"reporting_category\":\"charge\",\"source\":\"py_3S0Myh3RqEMUJuhk1YOqHu7u\",\"status\":\"available\",\"type\":\"payment\"}','2025-09-09 19:50:39'),
('txn_3S0NTO3RqEMUJuhk1SJnNWSt',25781,'CAD',984,24797,'charge','charge','ch_3S0NTO3RqEMUJuhk1mLsi46W',1756217022,1756771200,NULL,'{\"id\":\"txn_3S0NTO3RqEMUJuhk1SJnNWSt\",\"object\":\"balance_transaction\",\"amount\":25781,\"available_on\":1756771200,\"balance_type\":\"payments\",\"created\":1756217022,\"currency\":\"cad\",\"description\":null,\"exchange_rate\":1.35688,\"fee\":984,\"fee_details\":[{\"amount\":984,\"application\":null,\"currency\":\"cad\",\"description\":\"Stripe processing fees\",\"type\":\"stripe_fee\"}],\"net\":24797,\"reporting_category\":\"charge\",\"source\":\"ch_3S0NTO3RqEMUJuhk1mLsi46W\",\"status\":\"available\",\"type\":\"charge\"}','2025-09-09 19:50:39'),
('txn_3S0NUT3RqEMUJuhk11nqF6IM',25781,'CAD',984,24797,'charge','charge','ch_3S0NUT3RqEMUJuhk12VZNKkn',1756217089,1756771200,NULL,'{\"id\":\"txn_3S0NUT3RqEMUJuhk11nqF6IM\",\"object\":\"balance_transaction\",\"amount\":25781,\"available_on\":1756771200,\"balance_type\":\"payments\",\"created\":1756217089,\"currency\":\"cad\",\"description\":null,\"exchange_rate\":1.35688,\"fee\":984,\"fee_details\":[{\"amount\":984,\"application\":null,\"currency\":\"cad\",\"description\":\"Stripe processing fees\",\"type\":\"stripe_fee\"}],\"net\":24797,\"reporting_category\":\"charge\",\"source\":\"ch_3S0NUT3RqEMUJuhk12VZNKkn\",\"status\":\"available\",\"type\":\"charge\"}','2025-09-09 19:50:39'),
('txn_3S0NUx3RqEMUJuhk0ulDJzYY',25786,'CAD',984,24802,'charge','charge','ch_3S0NUx3RqEMUJuhk0SbNGRkI',1756217119,1756771200,NULL,'{\"id\":\"txn_3S0NUx3RqEMUJuhk0ulDJzYY\",\"object\":\"balance_transaction\",\"amount\":25786,\"available_on\":1756771200,\"balance_type\":\"payments\",\"created\":1756217119,\"currency\":\"cad\",\"description\":null,\"exchange_rate\":1.35714,\"fee\":984,\"fee_details\":[{\"amount\":984,\"application\":null,\"currency\":\"cad\",\"description\":\"Stripe processing fees\",\"type\":\"stripe_fee\"}],\"net\":24802,\"reporting_category\":\"charge\",\"source\":\"ch_3S0NUx3RqEMUJuhk0SbNGRkI\",\"status\":\"available\",\"type\":\"charge\"}','2025-09-09 19:50:39'),
('txn_3S1hIz3RqEMUJuhk0NBF54wc',6596,'CAD',274,6322,'charge','charge','ch_3S1hIz3RqEMUJuhk06SMM4oH',1756531585,1757116800,NULL,'{\"id\":\"txn_3S1hIz3RqEMUJuhk0NBF54wc\",\"object\":\"balance_transaction\",\"amount\":6596,\"available_on\":1757116800,\"balance_type\":\"payments\",\"created\":1756531585,\"currency\":\"cad\",\"description\":null,\"exchange_rate\":1.34621,\"fee\":274,\"fee_details\":[{\"amount\":274,\"application\":null,\"currency\":\"cad\",\"description\":\"Stripe processing fees\",\"type\":\"stripe_fee\"}],\"net\":6322,\"reporting_category\":\"charge\",\"source\":\"ch_3S1hIz3RqEMUJuhk06SMM4oH\",\"status\":\"available\",\"type\":\"charge\"}','2025-09-09 19:50:39'),
('txn_3S1hLL3RqEMUJuhk0dJsFOw4',2692,'CAD',130,2562,'charge','charge','ch_3S1hLL3RqEMUJuhk0uK9Ex55',1756531731,1757116800,NULL,'{\"id\":\"txn_3S1hLL3RqEMUJuhk0dJsFOw4\",\"object\":\"balance_transaction\",\"amount\":2692,\"available_on\":1757116800,\"balance_type\":\"payments\",\"created\":1756531731,\"currency\":\"cad\",\"description\":null,\"exchange_rate\":1.34621,\"fee\":130,\"fee_details\":[{\"amount\":130,\"application\":null,\"currency\":\"cad\",\"description\":\"Stripe processing fees\",\"type\":\"stripe_fee\"}],\"net\":2562,\"reporting_category\":\"charge\",\"source\":\"ch_3S1hLL3RqEMUJuhk0uK9Ex55\",\"status\":\"available\",\"type\":\"charge\"}','2025-09-09 19:50:39'),
('txn_3S1huh3RqEMUJuhk0lyy8KyJ',2693,'CAD',130,2563,'charge','charge','ch_3S1huh3RqEMUJuhk0ja9lLib',1756533923,1757116800,NULL,'{\"id\":\"txn_3S1huh3RqEMUJuhk0lyy8KyJ\",\"object\":\"balance_transaction\",\"amount\":2693,\"available_on\":1757116800,\"balance_type\":\"payments\",\"created\":1756533923,\"currency\":\"cad\",\"description\":null,\"exchange_rate\":1.34633,\"fee\":130,\"fee_details\":[{\"amount\":130,\"application\":null,\"currency\":\"cad\",\"description\":\"Stripe processing fees\",\"type\":\"stripe_fee\"}],\"net\":2563,\"reporting_category\":\"charge\",\"source\":\"ch_3S1huh3RqEMUJuhk0ja9lLib\",\"status\":\"available\",\"type\":\"charge\"}','2025-09-09 19:50:39'),
('txn_3S1i4J3RqEMUJuhk0EawgZHM',9424,'CAD',379,9045,'charge','charge','ch_3S1i4J3RqEMUJuhk0WqjZFbq',1756534519,1757116800,NULL,'{\"id\":\"txn_3S1i4J3RqEMUJuhk0EawgZHM\",\"object\":\"balance_transaction\",\"amount\":9424,\"available_on\":1757116800,\"balance_type\":\"payments\",\"created\":1756534519,\"currency\":\"cad\",\"description\":null,\"exchange_rate\":1.34633,\"fee\":379,\"fee_details\":[{\"amount\":379,\"application\":null,\"currency\":\"cad\",\"description\":\"Stripe processing fees\",\"type\":\"stripe_fee\"}],\"net\":9045,\"reporting_category\":\"charge\",\"source\":\"ch_3S1i4J3RqEMUJuhk0WqjZFbq\",\"status\":\"available\",\"type\":\"charge\"}','2025-09-09 19:50:39'),
('txn_3S2aAs3RqEMUJuhk1H7tiCai',2695,'CAD',130,2565,'charge','charge','ch_3S2aAs3RqEMUJuhk1kHsb7Dl',1756742502,1757289600,'Coaching order #11','{\"id\":\"txn_3S2aAs3RqEMUJuhk1H7tiCai\",\"object\":\"balance_transaction\",\"amount\":2695,\"available_on\":1757289600,\"balance_type\":\"payments\",\"created\":1756742502,\"currency\":\"cad\",\"description\":\"Coaching order #11\",\"exchange_rate\":1.34737,\"fee\":130,\"fee_details\":[{\"amount\":130,\"application\":null,\"currency\":\"cad\",\"description\":\"Stripe processing fees\",\"type\":\"stripe_fee\"}],\"net\":2565,\"reporting_category\":\"charge\",\"source\":\"ch_3S2aAs3RqEMUJuhk1kHsb7Dl\",\"status\":\"available\",\"type\":\"charge\"}','2025-09-09 19:50:39'),
('txn_3S2BbJ3RqEMUJuhk0oECahxm',2693,'CAD',130,2563,'charge','charge','ch_3S2BbJ3RqEMUJuhk0776CpG6',1756648041,1757203200,NULL,'{\"id\":\"txn_3S2BbJ3RqEMUJuhk0oECahxm\",\"object\":\"balance_transaction\",\"amount\":2693,\"available_on\":1757203200,\"balance_type\":\"payments\",\"created\":1756648041,\"currency\":\"cad\",\"description\":null,\"exchange_rate\":1.34633,\"fee\":130,\"fee_details\":[{\"amount\":130,\"application\":null,\"currency\":\"cad\",\"description\":\"Stripe processing fees\",\"type\":\"stripe_fee\"}],\"net\":2563,\"reporting_category\":\"charge\",\"source\":\"ch_3S2BbJ3RqEMUJuhk0776CpG6\",\"status\":\"available\",\"type\":\"charge\"}','2025-09-09 19:50:39'),
('txn_3S2bSa3RqEMUJuhk063Iflac',2697,'CAD',130,2567,'charge','charge','ch_3S2bSa3RqEMUJuhk0SryqgbG',1756747444,1757289600,'Coaching order #10','{\"id\":\"txn_3S2bSa3RqEMUJuhk063Iflac\",\"object\":\"balance_transaction\",\"amount\":2697,\"available_on\":1757289600,\"balance_type\":\"payments\",\"created\":1756747444,\"currency\":\"cad\",\"description\":\"Coaching order #10\",\"exchange_rate\":1.34825,\"fee\":130,\"fee_details\":[{\"amount\":130,\"application\":null,\"currency\":\"cad\",\"description\":\"Stripe processing fees\",\"type\":\"stripe_fee\"}],\"net\":2567,\"reporting_category\":\"charge\",\"source\":\"ch_3S2bSa3RqEMUJuhk0SryqgbG\",\"status\":\"available\",\"type\":\"charge\"}','2025-09-09 19:50:39'),
('txn_3S2c1p3RqEMUJuhk1A1Lg9vd',2697,'CAD',130,2567,'charge','charge','ch_3S2c1p3RqEMUJuhk1q6Hcuv5',1756749629,1757289600,'Coaching order #13','{\"id\":\"txn_3S2c1p3RqEMUJuhk1A1Lg9vd\",\"object\":\"balance_transaction\",\"amount\":2697,\"available_on\":1757289600,\"balance_type\":\"payments\",\"created\":1756749629,\"currency\":\"cad\",\"description\":\"Coaching order #13\",\"exchange_rate\":1.34825,\"fee\":130,\"fee_details\":[{\"amount\":130,\"application\":null,\"currency\":\"cad\",\"description\":\"Stripe processing fees\",\"type\":\"stripe_fee\"}],\"net\":2567,\"reporting_category\":\"charge\",\"source\":\"ch_3S2c1p3RqEMUJuhk1q6Hcuv5\",\"status\":\"available\",\"type\":\"charge\"}','2025-09-09 19:50:39'),
('txn_3S2coX3RqEMUJuhk18t19lHG',2696,'CAD',130,2566,'charge','charge','ch_3S2coX3RqEMUJuhk139MHXda',1756752649,1757289600,'Coaching order #9','{\"id\":\"txn_3S2coX3RqEMUJuhk18t19lHG\",\"object\":\"balance_transaction\",\"amount\":2696,\"available_on\":1757289600,\"balance_type\":\"payments\",\"created\":1756752649,\"currency\":\"cad\",\"description\":\"Coaching order #9\",\"exchange_rate\":1.34807,\"fee\":130,\"fee_details\":[{\"amount\":130,\"application\":null,\"currency\":\"cad\",\"description\":\"Stripe processing fees\",\"type\":\"stripe_fee\"}],\"net\":2566,\"reporting_category\":\"charge\",\"source\":\"ch_3S2coX3RqEMUJuhk139MHXda\",\"status\":\"available\",\"type\":\"charge\"}','2025-09-09 19:50:39'),
('txn_3S2doo3RqEMUJuhk0UjJMczz',1348,'CAD',80,1268,'charge','charge','ch_3S2doo3RqEMUJuhk0Pc3WKtj',1756756510,1757289600,'Order #46','{\"id\":\"txn_3S2doo3RqEMUJuhk0UjJMczz\",\"object\":\"balance_transaction\",\"amount\":1348,\"available_on\":1757289600,\"balance_type\":\"payments\",\"created\":1756756510,\"currency\":\"cad\",\"description\":\"Order #46\",\"exchange_rate\":1.34772,\"fee\":80,\"fee_details\":[{\"amount\":80,\"application\":null,\"currency\":\"cad\",\"description\":\"Stripe processing fees\",\"type\":\"stripe_fee\"}],\"net\":1268,\"reporting_category\":\"charge\",\"source\":\"ch_3S2doo3RqEMUJuhk0Pc3WKtj\",\"status\":\"available\",\"type\":\"charge\"}','2025-09-09 19:50:39'),
('txn_3S2dTq3RqEMUJuhk0P2vQR0L',1348,'CAD',80,1268,'charge','charge','ch_3S2dTq3RqEMUJuhk01qq8ghr',1756755210,1757289600,'Order #46','{\"id\":\"txn_3S2dTq3RqEMUJuhk0P2vQR0L\",\"object\":\"balance_transaction\",\"amount\":1348,\"available_on\":1757289600,\"balance_type\":\"payments\",\"created\":1756755210,\"currency\":\"cad\",\"description\":\"Order #46\",\"exchange_rate\":1.34772,\"fee\":80,\"fee_details\":[{\"amount\":80,\"application\":null,\"currency\":\"cad\",\"description\":\"Stripe processing fees\",\"type\":\"stripe_fee\"}],\"net\":1268,\"reporting_category\":\"charge\",\"source\":\"ch_3S2dTq3RqEMUJuhk01qq8ghr\",\"status\":\"available\",\"type\":\"charge\"}','2025-09-09 19:50:39'),
('txn_3S2eal3RqEMUJuhk09LWTKqD',2694,'CAD',130,2564,'charge','charge','ch_3S2eal3RqEMUJuhk0OZk8Dur',1756759484,1757289600,NULL,'{\"id\":\"txn_3S2eal3RqEMUJuhk09LWTKqD\",\"object\":\"balance_transaction\",\"amount\":2694,\"available_on\":1757289600,\"balance_type\":\"payments\",\"created\":1756759484,\"currency\":\"cad\",\"description\":null,\"exchange_rate\":1.3476,\"fee\":130,\"fee_details\":[{\"amount\":130,\"application\":null,\"currency\":\"cad\",\"description\":\"Stripe processing fees\",\"type\":\"stripe_fee\"}],\"net\":2564,\"reporting_category\":\"charge\",\"source\":\"ch_3S2eal3RqEMUJuhk0OZk8Dur\",\"status\":\"available\",\"type\":\"charge\"}','2025-09-09 19:50:39'),
('txn_3S2eL43RqEMUJuhk0HUFKUM8',4043,'CAD',180,3863,'charge','charge','ch_3S2eL43RqEMUJuhk0kP9sVvJ',1756758510,1757289600,'Order #49','{\"id\":\"txn_3S2eL43RqEMUJuhk0HUFKUM8\",\"object\":\"balance_transaction\",\"amount\":4043,\"available_on\":1757289600,\"balance_type\":\"payments\",\"created\":1756758510,\"currency\":\"cad\",\"description\":\"Order #49\",\"exchange_rate\":1.3476,\"fee\":180,\"fee_details\":[{\"amount\":180,\"application\":null,\"currency\":\"cad\",\"description\":\"Stripe processing fees\",\"type\":\"stripe_fee\"}],\"net\":3863,\"reporting_category\":\"charge\",\"source\":\"ch_3S2eL43RqEMUJuhk0kP9sVvJ\",\"status\":\"available\",\"type\":\"charge\"}','2025-09-09 19:50:39'),
('txn_3S2Rr03RqEMUJuhk0Pz4YuL8',2695,'CAD',130,2565,'charge','charge','ch_3S2Rr03RqEMUJuhk0opLhfwK',1756710518,1757289600,'Coaching order #7','{\"id\":\"txn_3S2Rr03RqEMUJuhk0Pz4YuL8\",\"object\":\"balance_transaction\",\"amount\":2695,\"available_on\":1757289600,\"balance_type\":\"payments\",\"created\":1756710518,\"currency\":\"cad\",\"description\":\"Coaching order #7\",\"exchange_rate\":1.34734,\"fee\":130,\"fee_details\":[{\"amount\":130,\"application\":null,\"currency\":\"cad\",\"description\":\"Stripe processing fees\",\"type\":\"stripe_fee\"}],\"net\":2565,\"reporting_category\":\"charge\",\"source\":\"ch_3S2Rr03RqEMUJuhk0opLhfwK\",\"status\":\"available\",\"type\":\"charge\"}','2025-09-09 19:50:39'),
('txn_3S2S1M3RqEMUJuhk1wOfKHJO',2695,'CAD',130,2565,'charge','charge','ch_3S2S1M3RqEMUJuhk1HWoRxCO',1756711160,1757289600,'Coaching order #7','{\"id\":\"txn_3S2S1M3RqEMUJuhk1wOfKHJO\",\"object\":\"balance_transaction\",\"amount\":2695,\"available_on\":1757289600,\"balance_type\":\"payments\",\"created\":1756711160,\"currency\":\"cad\",\"description\":\"Coaching order #7\",\"exchange_rate\":1.34734,\"fee\":130,\"fee_details\":[{\"amount\":130,\"application\":null,\"currency\":\"cad\",\"description\":\"Stripe processing fees\",\"type\":\"stripe_fee\"}],\"net\":2565,\"reporting_category\":\"charge\",\"source\":\"ch_3S2S1M3RqEMUJuhk1HWoRxCO\",\"status\":\"available\",\"type\":\"charge\"}','2025-09-09 19:50:39'),
('txn_3S2S5i3RqEMUJuhk1iHtHRcu',2695,'CAD',130,2565,'charge','charge','ch_3S2S5i3RqEMUJuhk1XcHuxmp',1756711430,1757289600,'Coaching order #7','{\"id\":\"txn_3S2S5i3RqEMUJuhk1iHtHRcu\",\"object\":\"balance_transaction\",\"amount\":2695,\"available_on\":1757289600,\"balance_type\":\"payments\",\"created\":1756711430,\"currency\":\"cad\",\"description\":\"Coaching order #7\",\"exchange_rate\":1.34734,\"fee\":130,\"fee_details\":[{\"amount\":130,\"application\":null,\"currency\":\"cad\",\"description\":\"Stripe processing fees\",\"type\":\"stripe_fee\"}],\"net\":2565,\"reporting_category\":\"charge\",\"source\":\"ch_3S2S5i3RqEMUJuhk1XcHuxmp\",\"status\":\"available\",\"type\":\"charge\"}','2025-09-09 19:50:39'),
('txn_3S2SGe3RqEMUJuhk1VgPMmka',2695,'CAD',130,2565,'charge','charge','ch_3S2SGe3RqEMUJuhk1OEMnB2W',1756712108,1757289600,'Coaching order #6','{\"id\":\"txn_3S2SGe3RqEMUJuhk1VgPMmka\",\"object\":\"balance_transaction\",\"amount\":2695,\"available_on\":1757289600,\"balance_type\":\"payments\",\"created\":1756712108,\"currency\":\"cad\",\"description\":\"Coaching order #6\",\"exchange_rate\":1.34734,\"fee\":130,\"fee_details\":[{\"amount\":130,\"application\":null,\"currency\":\"cad\",\"description\":\"Stripe processing fees\",\"type\":\"stripe_fee\"}],\"net\":2565,\"reporting_category\":\"charge\",\"source\":\"ch_3S2SGe3RqEMUJuhk1OEMnB2W\",\"status\":\"available\",\"type\":\"charge\"}','2025-09-09 19:50:39'),
('txn_3S4c0R3RqEMUJuhk07fswsU4',2711,'CAD',130,2581,'charge','charge','ch_3S4c0R3RqEMUJuhk08hK9yBf',1757226200,1757808000,'Coaching order #15','{\"id\":\"txn_3S4c0R3RqEMUJuhk07fswsU4\",\"object\":\"balance_transaction\",\"amount\":2711,\"available_on\":1757808000,\"balance_type\":\"payments\",\"created\":1757226200,\"currency\":\"cad\",\"description\":\"Coaching order #15\",\"exchange_rate\":1.35532,\"fee\":130,\"fee_details\":[{\"amount\":130,\"application\":null,\"currency\":\"cad\",\"description\":\"Stripe processing fees\",\"type\":\"stripe_fee\"}],\"net\":2581,\"reporting_category\":\"charge\",\"source\":\"ch_3S4c0R3RqEMUJuhk08hK9yBf\",\"status\":\"pending\",\"type\":\"charge\"}','2025-09-09 19:50:39'),
('txn_3S4d3S3RqEMUJuhk05oJTb3G',2711,'CAD',130,2581,'charge','charge','ch_3S4d3S3RqEMUJuhk0PiRn8mH',1757230230,1757808000,'Coaching order #15','{\"id\":\"txn_3S4d3S3RqEMUJuhk05oJTb3G\",\"object\":\"balance_transaction\",\"amount\":2711,\"available_on\":1757808000,\"balance_type\":\"payments\",\"created\":1757230230,\"currency\":\"cad\",\"description\":\"Coaching order #15\",\"exchange_rate\":1.35532,\"fee\":130,\"fee_details\":[{\"amount\":130,\"application\":null,\"currency\":\"cad\",\"description\":\"Stripe processing fees\",\"type\":\"stripe_fee\"}],\"net\":2581,\"reporting_category\":\"charge\",\"source\":\"ch_3S4d3S3RqEMUJuhk0PiRn8mH\",\"status\":\"pending\",\"type\":\"charge\"}','2025-09-09 19:50:39'),
('txn_3S4dYQ3RqEMUJuhk02ONvvES',2711,'CAD',130,2581,'charge','charge','ch_3S4dYQ3RqEMUJuhk0kF6C9e5',1757232150,1757808000,'Coaching order #15','{\"id\":\"txn_3S4dYQ3RqEMUJuhk02ONvvES\",\"object\":\"balance_transaction\",\"amount\":2711,\"available_on\":1757808000,\"balance_type\":\"payments\",\"created\":1757232150,\"currency\":\"cad\",\"description\":\"Coaching order #15\",\"exchange_rate\":1.35532,\"fee\":130,\"fee_details\":[{\"amount\":130,\"application\":null,\"currency\":\"cad\",\"description\":\"Stripe processing fees\",\"type\":\"stripe_fee\"}],\"net\":2581,\"reporting_category\":\"charge\",\"source\":\"ch_3S4dYQ3RqEMUJuhk0kF6C9e5\",\"status\":\"pending\",\"type\":\"charge\"}','2025-09-09 19:50:39'),
('txn_3S4dZo3RqEMUJuhk0tSD0k5R',2711,'CAD',130,2581,'charge','charge','ch_3S4dZo3RqEMUJuhk0qVQ73Oa',1757232236,1757808000,'Coaching order #15','{\"id\":\"txn_3S4dZo3RqEMUJuhk0tSD0k5R\",\"object\":\"balance_transaction\",\"amount\":2711,\"available_on\":1757808000,\"balance_type\":\"payments\",\"created\":1757232236,\"currency\":\"cad\",\"description\":\"Coaching order #15\",\"exchange_rate\":1.35532,\"fee\":130,\"fee_details\":[{\"amount\":130,\"application\":null,\"currency\":\"cad\",\"description\":\"Stripe processing fees\",\"type\":\"stripe_fee\"}],\"net\":2581,\"reporting_category\":\"charge\",\"source\":\"ch_3S4dZo3RqEMUJuhk0qVQ73Oa\",\"status\":\"pending\",\"type\":\"charge\"}','2025-09-09 19:50:39'),
('txn_3S4eDn3RqEMUJuhk1Kq1ZCgu',2711,'CAD',130,2581,'charge','charge','ch_3S4eDn3RqEMUJuhk1epNZ6FN',1757234715,1757808000,'Coaching order #15','{\"id\":\"txn_3S4eDn3RqEMUJuhk1Kq1ZCgu\",\"object\":\"balance_transaction\",\"amount\":2711,\"available_on\":1757808000,\"balance_type\":\"payments\",\"created\":1757234715,\"currency\":\"cad\",\"description\":\"Coaching order #15\",\"exchange_rate\":1.35532,\"fee\":130,\"fee_details\":[{\"amount\":130,\"application\":null,\"currency\":\"cad\",\"description\":\"Stripe processing fees\",\"type\":\"stripe_fee\"}],\"net\":2581,\"reporting_category\":\"charge\",\"source\":\"ch_3S4eDn3RqEMUJuhk1epNZ6FN\",\"status\":\"pending\",\"type\":\"charge\"}','2025-09-09 19:50:39'),
('txn_3S4g7u3RqEMUJuhk1UIeDj64',1355,'CAD',80,1275,'charge','charge','ch_3S4g7u3RqEMUJuhk1nAfYhgI',1757242038,1757808000,'Order #53 (saved card)','{\"id\":\"txn_3S4g7u3RqEMUJuhk1UIeDj64\",\"object\":\"balance_transaction\",\"amount\":1355,\"available_on\":1757808000,\"balance_type\":\"payments\",\"created\":1757242038,\"currency\":\"cad\",\"description\":\"Order #53 (saved card)\",\"exchange_rate\":1.35532,\"fee\":80,\"fee_details\":[{\"amount\":80,\"application\":null,\"currency\":\"cad\",\"description\":\"Stripe processing fees\",\"type\":\"stripe_fee\"}],\"net\":1275,\"reporting_category\":\"charge\",\"source\":\"ch_3S4g7u3RqEMUJuhk1nAfYhgI\",\"status\":\"pending\",\"type\":\"charge\"}','2025-09-09 19:50:39'),
('txn_3S4hkE3RqEMUJuhk13SX1ppb',2711,'CAD',130,2581,'charge','charge','ch_3S4hkE3RqEMUJuhk10FZvnAJ',1757248258,1757808000,NULL,'{\"id\":\"txn_3S4hkE3RqEMUJuhk13SX1ppb\",\"object\":\"balance_transaction\",\"amount\":2711,\"available_on\":1757808000,\"balance_type\":\"payments\",\"created\":1757248258,\"currency\":\"cad\",\"description\":null,\"exchange_rate\":1.35532,\"fee\":130,\"fee_details\":[{\"amount\":130,\"application\":null,\"currency\":\"cad\",\"description\":\"Stripe processing fees\",\"type\":\"stripe_fee\"}],\"net\":2581,\"reporting_category\":\"charge\",\"source\":\"ch_3S4hkE3RqEMUJuhk10FZvnAJ\",\"status\":\"pending\",\"type\":\"charge\"}','2025-09-09 19:50:39'),
('txn_3S4hnT3RqEMUJuhk1TTda6GJ',2711,'CAD',130,2581,'charge','charge','ch_3S4hnT3RqEMUJuhk1vaVtweN',1757248459,1757808000,NULL,'{\"id\":\"txn_3S4hnT3RqEMUJuhk1TTda6GJ\",\"object\":\"balance_transaction\",\"amount\":2711,\"available_on\":1757808000,\"balance_type\":\"payments\",\"created\":1757248459,\"currency\":\"cad\",\"description\":null,\"exchange_rate\":1.35532,\"fee\":130,\"fee_details\":[{\"amount\":130,\"application\":null,\"currency\":\"cad\",\"description\":\"Stripe processing fees\",\"type\":\"stripe_fee\"}],\"net\":2581,\"reporting_category\":\"charge\",\"source\":\"ch_3S4hnT3RqEMUJuhk1vaVtweN\",\"status\":\"pending\",\"type\":\"charge\"}','2025-09-09 19:50:39'),
('txn_3S4ilM3RqEMUJuhk1F1K9yJf',2711,'CAD',130,2581,'charge','charge','ch_3S4ilM3RqEMUJuhk1XTZIe1D',1757252172,1757808000,NULL,'{\"id\":\"txn_3S4ilM3RqEMUJuhk1F1K9yJf\",\"object\":\"balance_transaction\",\"amount\":2711,\"available_on\":1757808000,\"balance_type\":\"payments\",\"created\":1757252172,\"currency\":\"cad\",\"description\":null,\"exchange_rate\":1.35532,\"fee\":130,\"fee_details\":[{\"amount\":130,\"application\":null,\"currency\":\"cad\",\"description\":\"Stripe processing fees\",\"type\":\"stripe_fee\"}],\"net\":2581,\"reporting_category\":\"charge\",\"source\":\"ch_3S4ilM3RqEMUJuhk1XTZIe1D\",\"status\":\"pending\",\"type\":\"charge\"}','2025-09-09 19:50:39'),
('txn_3S4iRA3RqEMUJuhk0osO0xMd',2711,'CAD',130,2581,'charge','charge','ch_3S4iRA3RqEMUJuhk0oOAcOD7',1757250921,1757808000,NULL,'{\"id\":\"txn_3S4iRA3RqEMUJuhk0osO0xMd\",\"object\":\"balance_transaction\",\"amount\":2711,\"available_on\":1757808000,\"balance_type\":\"payments\",\"created\":1757250921,\"currency\":\"cad\",\"description\":null,\"exchange_rate\":1.35532,\"fee\":130,\"fee_details\":[{\"amount\":130,\"application\":null,\"currency\":\"cad\",\"description\":\"Stripe processing fees\",\"type\":\"stripe_fee\"}],\"net\":2581,\"reporting_category\":\"charge\",\"source\":\"ch_3S4iRA3RqEMUJuhk0oOAcOD7\",\"status\":\"pending\",\"type\":\"charge\"}','2025-09-09 19:50:39'),
('txn_3S4iyc3RqEMUJuhk1SHp52Zl',3930,'CAD',175,3755,'charge','charge','ch_3S4iyc3RqEMUJuhk1f2fzX5U',1757252995,1757808000,NULL,'{\"id\":\"txn_3S4iyc3RqEMUJuhk1SHp52Zl\",\"object\":\"balance_transaction\",\"amount\":3930,\"available_on\":1757808000,\"balance_type\":\"payments\",\"created\":1757252995,\"currency\":\"cad\",\"description\":null,\"exchange_rate\":1.35532,\"fee\":175,\"fee_details\":[{\"amount\":175,\"application\":null,\"currency\":\"cad\",\"description\":\"Stripe processing fees\",\"type\":\"stripe_fee\"}],\"net\":3755,\"reporting_category\":\"charge\",\"source\":\"ch_3S4iyc3RqEMUJuhk1f2fzX5U\",\"status\":\"pending\",\"type\":\"charge\"}','2025-09-09 19:50:39'),
('txn_3S4j4G3RqEMUJuhk0DC9cstx',2711,'CAD',130,2581,'charge','charge','ch_3S4j4G3RqEMUJuhk02x9Lzez',1757253345,1757808000,'Course order #5','{\"id\":\"txn_3S4j4G3RqEMUJuhk0DC9cstx\",\"object\":\"balance_transaction\",\"amount\":2711,\"available_on\":1757808000,\"balance_type\":\"payments\",\"created\":1757253345,\"currency\":\"cad\",\"description\":\"Course order #5\",\"exchange_rate\":1.35532,\"fee\":130,\"fee_details\":[{\"amount\":130,\"application\":null,\"currency\":\"cad\",\"description\":\"Stripe processing fees\",\"type\":\"stripe_fee\"}],\"net\":2581,\"reporting_category\":\"charge\",\"source\":\"ch_3S4j4G3RqEMUJuhk02x9Lzez\",\"status\":\"pending\",\"type\":\"charge\"}','2025-09-09 19:50:39'),
('txn_3S4jal3RqEMUJuhk1O6bJUe6',2711,'CAD',130,2581,'charge','charge','ch_3S4jal3RqEMUJuhk1YOnlLYn',1757255359,1757808000,'Course order #5','{\"id\":\"txn_3S4jal3RqEMUJuhk1O6bJUe6\",\"object\":\"balance_transaction\",\"amount\":2711,\"available_on\":1757808000,\"balance_type\":\"payments\",\"created\":1757255359,\"currency\":\"cad\",\"description\":\"Course order #5\",\"exchange_rate\":1.35532,\"fee\":130,\"fee_details\":[{\"amount\":130,\"application\":null,\"currency\":\"cad\",\"description\":\"Stripe processing fees\",\"type\":\"stripe_fee\"}],\"net\":2581,\"reporting_category\":\"charge\",\"source\":\"ch_3S4jal3RqEMUJuhk1YOnlLYn\",\"status\":\"pending\",\"type\":\"charge\"}','2025-09-09 19:50:39'),
('txn_3S4jcB3RqEMUJuhk0vRpypTW',2711,'CAD',130,2581,'charge','charge','ch_3S4jcB3RqEMUJuhk04pzP1VJ',1757255448,1757808000,'Course order #5','{\"id\":\"txn_3S4jcB3RqEMUJuhk0vRpypTW\",\"object\":\"balance_transaction\",\"amount\":2711,\"available_on\":1757808000,\"balance_type\":\"payments\",\"created\":1757255448,\"currency\":\"cad\",\"description\":\"Course order #5\",\"exchange_rate\":1.35532,\"fee\":130,\"fee_details\":[{\"amount\":130,\"application\":null,\"currency\":\"cad\",\"description\":\"Stripe processing fees\",\"type\":\"stripe_fee\"}],\"net\":2581,\"reporting_category\":\"charge\",\"source\":\"ch_3S4jcB3RqEMUJuhk04pzP1VJ\",\"status\":\"pending\",\"type\":\"charge\"}','2025-09-09 19:50:39'),
('txn_3S4jeK3RqEMUJuhk05kq113v',2711,'CAD',130,2581,'charge','charge','ch_3S4jeK3RqEMUJuhk0ceDPSkW',1757255581,1757808000,'Course order #5','{\"id\":\"txn_3S4jeK3RqEMUJuhk05kq113v\",\"object\":\"balance_transaction\",\"amount\":2711,\"available_on\":1757808000,\"balance_type\":\"payments\",\"created\":1757255581,\"currency\":\"cad\",\"description\":\"Course order #5\",\"exchange_rate\":1.35532,\"fee\":130,\"fee_details\":[{\"amount\":130,\"application\":null,\"currency\":\"cad\",\"description\":\"Stripe processing fees\",\"type\":\"stripe_fee\"}],\"net\":2581,\"reporting_category\":\"charge\",\"source\":\"ch_3S4jeK3RqEMUJuhk0ceDPSkW\",\"status\":\"pending\",\"type\":\"charge\"}','2025-09-09 19:50:39'),
('txn_3S4jk63RqEMUJuhk0cCsWkUb',2711,'CAD',130,2581,'charge','charge','ch_3S4jk63RqEMUJuhk0wtg1rQk',1757255938,1757808000,'Course order #5','{\"id\":\"txn_3S4jk63RqEMUJuhk0cCsWkUb\",\"object\":\"balance_transaction\",\"amount\":2711,\"available_on\":1757808000,\"balance_type\":\"payments\",\"created\":1757255938,\"currency\":\"cad\",\"description\":\"Course order #5\",\"exchange_rate\":1.35532,\"fee\":130,\"fee_details\":[{\"amount\":130,\"application\":null,\"currency\":\"cad\",\"description\":\"Stripe processing fees\",\"type\":\"stripe_fee\"}],\"net\":2581,\"reporting_category\":\"charge\",\"source\":\"ch_3S4jk63RqEMUJuhk0wtg1rQk\",\"status\":\"pending\",\"type\":\"charge\"}','2025-09-09 19:50:39'),
('txn_3S4k8b3RqEMUJuhk0toa1ohn',6641,'CAD',276,6365,'charge','charge','ch_3S4k8b3RqEMUJuhk0fdRgANZ',1757257457,1757808000,'Course order #13','{\"id\":\"txn_3S4k8b3RqEMUJuhk0toa1ohn\",\"object\":\"balance_transaction\",\"amount\":6641,\"available_on\":1757808000,\"balance_type\":\"payments\",\"created\":1757257457,\"currency\":\"cad\",\"description\":\"Course order #13\",\"exchange_rate\":1.35532,\"fee\":276,\"fee_details\":[{\"amount\":276,\"application\":null,\"currency\":\"cad\",\"description\":\"Stripe processing fees\",\"type\":\"stripe_fee\"}],\"net\":6365,\"reporting_category\":\"charge\",\"source\":\"ch_3S4k8b3RqEMUJuhk0fdRgANZ\",\"status\":\"pending\",\"type\":\"charge\"}','2025-09-09 19:50:39'),
('txn_3S4kgP3RqEMUJuhk0F8y37p1',2711,'CAD',130,2581,'charge','charge','ch_3S4kgP3RqEMUJuhk08PQBSXe',1757259554,1757808000,'Course order #7','{\"id\":\"txn_3S4kgP3RqEMUJuhk0F8y37p1\",\"object\":\"balance_transaction\",\"amount\":2711,\"available_on\":1757808000,\"balance_type\":\"payments\",\"created\":1757259554,\"currency\":\"cad\",\"description\":\"Course order #7\",\"exchange_rate\":1.35532,\"fee\":130,\"fee_details\":[{\"amount\":130,\"application\":null,\"currency\":\"cad\",\"description\":\"Stripe processing fees\",\"type\":\"stripe_fee\"}],\"net\":2581,\"reporting_category\":\"charge\",\"source\":\"ch_3S4kgP3RqEMUJuhk08PQBSXe\",\"status\":\"pending\",\"type\":\"charge\"}','2025-09-09 19:50:39'),
('txn_3S4klk3RqEMUJuhk00WOFd42',2711,'CAD',130,2581,'charge','charge','ch_3S4klk3RqEMUJuhk0tFqkMh4',1757259884,1757808000,'Course order #7','{\"id\":\"txn_3S4klk3RqEMUJuhk00WOFd42\",\"object\":\"balance_transaction\",\"amount\":2711,\"available_on\":1757808000,\"balance_type\":\"payments\",\"created\":1757259884,\"currency\":\"cad\",\"description\":\"Course order #7\",\"exchange_rate\":1.35532,\"fee\":130,\"fee_details\":[{\"amount\":130,\"application\":null,\"currency\":\"cad\",\"description\":\"Stripe processing fees\",\"type\":\"stripe_fee\"}],\"net\":2581,\"reporting_category\":\"charge\",\"source\":\"ch_3S4klk3RqEMUJuhk0tFqkMh4\",\"status\":\"pending\",\"type\":\"charge\"}','2025-09-09 19:50:39');
/*!40000 ALTER TABLE `stripe_balance_txns` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `stripe_payouts`
--

DROP TABLE IF EXISTS `stripe_payouts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `stripe_payouts` (
  `id` varchar(64) NOT NULL,
  `amount` bigint(20) NOT NULL,
  `currency` char(3) NOT NULL,
  `status` varchar(32) NOT NULL,
  `arrival_date` int(11) DEFAULT NULL,
  `method` varchar(32) DEFAULT NULL,
  `raw` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`raw`)),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stripe_payouts`
--

LOCK TABLES `stripe_payouts` WRITE;
/*!40000 ALTER TABLE `stripe_payouts` DISABLE KEYS */;
/*!40000 ALTER TABLE `stripe_payouts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `stripe_sync_state`
--

DROP TABLE IF EXISTS `stripe_sync_state`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `stripe_sync_state` (
  `id` tinyint(3) unsigned NOT NULL DEFAULT 1,
  `last_balance_txn_id` varchar(64) DEFAULT NULL,
  `last_balance_txn_created` int(11) DEFAULT NULL,
  `last_payout_id` varchar(64) DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stripe_sync_state`
--

LOCK TABLES `stripe_sync_state` WRITE;
/*!40000 ALTER TABLE `stripe_sync_state` DISABLE KEYS */;
INSERT INTO `stripe_sync_state` VALUES
(1,'txn_3Rw0Fo3RqEMUJuhk1zqhNL0t',1755174456,NULL,'2025-09-09 19:50:39');
/*!40000 ALTER TABLE `stripe_sync_state` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `stripe_webhook_events`
--

DROP TABLE IF EXISTS `stripe_webhook_events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `stripe_webhook_events` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `event_id` varchar(255) NOT NULL,
  `type` varchar(255) NOT NULL,
  `payload` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`payload`)),
  `processed_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `event_id` (`event_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stripe_webhook_events`
--

LOCK TABLES `stripe_webhook_events` WRITE;
/*!40000 ALTER TABLE `stripe_webhook_events` DISABLE KEYS */;
/*!40000 ALTER TABLE `stripe_webhook_events` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_connections`
--

DROP TABLE IF EXISTS `user_connections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_connections` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `connected_user_id` int(11) NOT NULL,
  `status` enum('pending','connected','rejected') DEFAULT 'pending',
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_connection` (`user_id`,`connected_user_id`),
  KEY `connected_user_id` (`connected_user_id`),
  KEY `idx_user_connected` (`user_id`,`connected_user_id`),
  KEY `idx_connected_user` (`connected_user_id`,`user_id`),
  KEY `idx_uc_user_connected` (`user_id`,`connected_user_id`),
  KEY `idx_uc_connected_user` (`connected_user_id`,`user_id`),
  KEY `idx_uc_status` (`status`),
  CONSTRAINT `user_connections_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `user_connections_ibfk_2` FOREIGN KEY (`connected_user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=49 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_connections`
--

LOCK TABLES `user_connections` WRITE;
/*!40000 ALTER TABLE `user_connections` DISABLE KEYS */;
INSERT INTO `user_connections` VALUES
(3,3,4,'pending','2025-08-08 20:15:45','2025-08-08 20:15:45'),
(4,3,1,'pending','2025-08-08 21:16:24','2025-08-08 21:16:24'),
(5,3,3,'pending','2025-08-15 19:48:51','2025-08-15 19:48:51'),
(6,3,5,'pending','2025-08-15 19:49:32','2025-08-15 19:49:32'),
(7,4,5,'pending','2025-08-16 04:38:18','2025-08-16 04:38:18'),
(8,4,3,'pending','2025-08-16 04:38:19','2025-08-16 04:38:19'),
(9,4,1,'pending','2025-08-20 06:17:07','2025-08-20 06:17:07'),
(10,1,5,'pending','2025-08-20 10:11:15','2025-08-20 10:11:15'),
(11,1,3,'pending','2025-08-20 10:11:16','2025-08-20 10:11:16'),
(12,6,5,'pending','2025-08-20 13:52:12','2025-08-20 13:52:12'),
(13,6,3,'pending','2025-08-20 13:52:13','2025-08-20 13:52:13'),
(14,6,1,'pending','2025-08-20 13:52:15','2025-08-20 13:52:15'),
(15,9,7,'pending','2025-09-13 07:38:14','2025-09-13 07:38:14'),
(16,9,6,'pending','2025-09-13 07:38:14','2025-09-13 07:38:14'),
(17,9,1,'pending','2025-09-13 07:38:15','2025-09-13 07:38:15'),
(18,9,3,'pending','2025-09-13 07:38:17','2025-09-13 07:38:17'),
(19,9,5,'pending','2025-09-13 07:38:18','2025-09-13 07:38:18'),
(21,9,10,'pending','2025-09-13 07:46:12','2025-09-13 07:46:12'),
(23,13,10,'pending','2025-09-13 07:58:27','2025-09-13 07:58:27'),
(24,13,7,'pending','2025-09-13 07:58:28','2025-09-13 07:58:28'),
(25,13,6,'pending','2025-09-13 07:58:30','2025-09-13 07:58:30'),
(29,13,5,'pending','2025-09-13 10:57:16','2025-09-13 10:57:16'),
(30,13,3,'pending','2025-09-13 10:57:17','2025-09-13 10:57:17'),
(32,6,6,'pending','2025-09-13 15:07:13','2025-09-13 15:07:13'),
(33,10,3,'pending','2025-09-13 15:41:52','2025-09-13 15:41:52'),
(34,3,10,'pending','2025-09-25 10:08:36','2025-09-25 10:08:36'),
(35,3,7,'pending','2025-09-25 10:08:38','2025-09-25 10:08:38'),
(36,3,6,'pending','2025-09-25 10:08:41','2025-09-25 10:08:41'),
(37,2,3,'pending','2025-09-25 10:27:13','2025-09-25 10:27:13'),
(38,2,10,'pending','2025-09-25 10:27:14','2025-09-25 10:27:14'),
(39,2,7,'pending','2025-09-25 10:27:15','2025-09-25 10:27:15'),
(40,2,6,'pending','2025-09-25 10:27:16','2025-09-25 10:27:16'),
(41,2,5,'pending','2025-09-25 10:27:17','2025-09-25 10:27:17'),
(42,2,1,'pending','2025-09-25 10:27:18','2025-09-25 10:27:18'),
(43,6,15,'pending','2025-09-28 15:26:10','2025-09-28 15:26:10'),
(44,6,16,'pending','2025-09-28 15:27:56','2025-09-28 15:27:56'),
(45,16,6,'pending','2025-09-28 17:35:55','2025-09-28 17:35:55'),
(46,3,16,'pending','2025-10-05 05:08:01','2025-10-05 05:08:01'),
(47,17,6,'pending','2025-10-05 16:15:57','2025-10-05 16:15:57'),
(48,6,18,'pending','2025-10-13 18:03:33','2025-10-13 18:03:33');
/*!40000 ALTER TABLE `user_connections` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_industries`
--

DROP TABLE IF EXISTS `user_industries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_industries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `industry_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `industry_id` (`industry_id`),
  CONSTRAINT `user_industries_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `user_industries_ibfk_2` FOREIGN KEY (`industry_id`) REFERENCES `industries` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=64 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_industries`
--

LOCK TABLES `user_industries` WRITE;
/*!40000 ALTER TABLE `user_industries` DISABLE KEYS */;
INSERT INTO `user_industries` VALUES
(32,1,1),
(35,2,1),
(37,7,2),
(38,8,2),
(41,10,2),
(42,9,2),
(44,11,1),
(45,12,2),
(46,13,2),
(54,3,2),
(56,6,2),
(57,15,1),
(58,16,2),
(59,16,1),
(61,18,2),
(63,17,2);
/*!40000 ALTER TABLE `user_industries` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_roles`
--

DROP TABLE IF EXISTS `user_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_roles` (
  `user_id` int(11) NOT NULL,
  `role_id` int(11) NOT NULL,
  PRIMARY KEY (`user_id`,`role_id`),
  KEY `role_id` (`role_id`),
  CONSTRAINT `fk_user_roles_role` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_roles`
--

LOCK TABLES `user_roles` WRITE;
/*!40000 ALTER TABLE `user_roles` DISABLE KEYS */;
INSERT INTO `user_roles` VALUES
(1,1),
(1,2),
(3,2),
(4,1);
/*!40000 ALTER TABLE `user_roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_wallets`
--

DROP TABLE IF EXISTS `user_wallets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_wallets` (
  `user_id` int(11) NOT NULL,
  `available` decimal(12,2) NOT NULL DEFAULT 0.00,
  `pending` decimal(12,2) NOT NULL DEFAULT 0.00,
  `reserved` decimal(12,2) NOT NULL DEFAULT 0.00,
  `withdrawn_total` decimal(12,2) NOT NULL DEFAULT 0.00,
  `currency` char(3) NOT NULL DEFAULT 'USD',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`user_id`),
  CONSTRAINT `fk_wallet_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_wallets`
--

LOCK TABLES `user_wallets` WRITE;
/*!40000 ALTER TABLE `user_wallets` DISABLE KEYS */;
INSERT INTO `user_wallets` VALUES
(1,0.00,17.12,0.00,0.00,'USD','2025-09-07 20:21:51','2025-09-07 21:42:40'),
(3,337.14,390.10,30.00,0.00,'USD','2025-09-07 20:21:42','2025-10-05 07:34:09'),
(4,0.00,0.00,0.00,0.00,'USD','2025-09-12 19:35:14','2025-09-12 19:35:14'),
(6,194.46,5.82,0.00,0.00,'USD','2025-09-09 19:03:25','2025-10-05 16:28:28'),
(7,0.00,0.00,0.00,0.00,'USD','2025-09-13 08:01:46','2025-09-13 08:01:46'),
(10,0.00,0.00,0.00,0.00,'USD','2025-09-14 06:35:47','2025-09-14 06:35:47'),
(16,0.00,0.00,0.00,0.00,'USD','2025-09-28 17:08:26','2025-09-28 17:08:26');
/*!40000 ALTER TABLE `user_wallets` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(255) NOT NULL,
  `phone_number` varchar(32) DEFAULT NULL,
  `date_of_birth` date DEFAULT NULL,
  `password` varchar(255) NOT NULL,
  `password_changed_at` datetime DEFAULT NULL,
  `role_id` int(11) NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `deleted_at` datetime DEFAULT NULL,
  `profile_photo` text DEFAULT NULL,
  `city` varchar(100) DEFAULT NULL,
  `state` varchar(100) DEFAULT NULL,
  `country` varchar(100) DEFAULT NULL,
  `status` enum('active','inactive') NOT NULL DEFAULT 'active',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `first_name` varchar(100) DEFAULT NULL,
  `last_name` varchar(100) DEFAULT NULL,
  `is_verified` tinyint(1) DEFAULT 0,
  `location` varchar(255) DEFAULT NULL,
  `timezone` varchar(100) DEFAULT NULL,
  `stripe_customer_id` varchar(255) DEFAULT NULL,
  `stripe_default_payment_method` varchar(255) DEFAULT NULL,
  `public_slug` varchar(120) DEFAULT NULL,
  `stripe_account_id` varchar(64) DEFAULT NULL,
  `stripe_country` char(2) DEFAULT NULL,
  `stripe_charges_enabled` tinyint(1) DEFAULT 0,
  `stripe_payouts_enabled` tinyint(1) DEFAULT 0,
  `stripe_requirements_json` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`stripe_requirements_json`)),
  `stripe_connect_supported` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `uq_users_email` (`email`),
  UNIQUE KEY `uniq_users_public_slug` (`public_slug`),
  UNIQUE KEY `uq_users_public_slug` (`public_slug`),
  KEY `role_id` (`role_id`),
  KEY `idx_users_stripe_customer_id` (`stripe_customer_id`),
  CONSTRAINT `fk_users_role` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`),
  CONSTRAINT `users_ibfk_1` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES
(1,'abutaleb142@gmail.com',NULL,NULL,'$2a$10$RXiuogRf0xrA8eXRgDZblektWOnKCuL3r1kJIINLYa0CGCdo8Ymeu','2025-08-20 10:13:13',2,1,NULL,'/uploads/profile_photos/1755444112126-david-kazi.jpg','','','','active','2025-08-05 07:05:07','2025-08-20 10:13:13','Mohammad Abu','Taleb',0,'','','cus_Sst8O2EL92yt2P','pm_1Rx7N83RqEMUJuhkQY14JnBc','mohammad-abu-taleb',NULL,NULL,0,0,NULL,1),
(2,'mustafizur142@gmail.com','019287543','1991-07-15','$2a$10$ytBh93tBsRM6TrGiXNvxrusnXfUvQ/NpTSeFErcDLXjYTgGgYG/Rq',NULL,5,1,NULL,'/uploads/profile_photos/1756021977140-Ahmed.jpg','Dhaka','Dhaka','Bangladesh','active','2025-08-05 07:07:41','2025-09-14 07:22:40','Mustafizur','Rahman',1,'Jessore Road','Asia/Dhaka','cus_SvRQWVuL5yfBEp',NULL,NULL,NULL,NULL,0,0,NULL,1),
(3,'imranhossen1119999@gmail.com','1234353535',NULL,'$2a$10$gHsVq1qLWS65hjd6D7ufDOTMka4bzln7vrcdUJZmkfF.Sxq94LEUG','2025-08-10 14:52:23',2,1,NULL,'/uploads/profile_photos/1757838490533-rubayet ferdaus.jpg','Jessore','Jessore','CANADA','active','2025-08-05 07:14:34','2025-09-14 08:28:10','Imran','Hossen',1,'Jessore mani Road','Asia/Dhaka','cus_Ss5IuKQ2Wybk0m',NULL,'imran-hossen','acct_1S6HXd4I4GlhuBRq','CA',0,0,NULL,1),
(4,'admin@example.com','',NULL,'$2a$10$BNkZhxIFJ3qRC5pHbOdTKe8w5G7Fm/oE6NrVnuWad/NpjSuG0BA6K',NULL,1,1,NULL,'/uploads/profile_photos/1758922797374_passport_photo.jpg','Dhaka 2','Dhaka','Bangladesh','active','2025-08-05 07:20:47','2025-09-26 21:39:59','MOHAMMAD ABU','TALEB',1,'Dhaka, Dhaka','Asia/Dhaka','cus_Srql9qnzJPpwCc','pm_1Rw8v33RqEMUJuhkSAN3rnay',NULL,NULL,NULL,0,0,NULL,1),
(5,'admin2@example.com',NULL,NULL,'$2a$10$GwSLMgsCmCen/9Gqw5mIM.OLgHB7xjx4abIH0QwDqn0Pp.w7k2ntC',NULL,2,1,NULL,'/uploads/profile_photos/1755289622403-apon.jpg','San Frincisco','CA','United States','active','2025-08-06 09:32:28','2025-09-12 18:49:24','Mr Alex','Joe',0,'San Frincisco, CA','Pacific/Midway','cus_StdplrRRlszAZY',NULL,'mr-alex-joe',NULL,NULL,0,0,NULL,1),
(6,'norman@prosfata.com','+1 613-770-4810','1979-07-28','$2a$10$P2RctU8oIgjylPPpV5H4MeIB8arHuZFkDZ9L6rYPbQsX2JCyYQJ0a','2025-09-20 15:55:46',2,1,NULL,'/uploads/profile_photos/1757778356679-Norman Musengimana.jpeg','Kingston','ON','Canada','active','2025-08-20 13:49:12','2025-09-26 01:24:34','Norman','Musengimana',1,'Kingston, ON','US/Eastern','cus_T7fkkEtN4YFHMg',NULL,'norman-musengimana',NULL,NULL,0,0,NULL,1),
(7,'Pinkykhatun13244@gmail.com',NULL,NULL,'$2a$10$5GBNdQAkw0LcKIBqZF7Hc.FAytc2SMwWrSBZdMbEJ6hCfTA5ugU9O',NULL,2,1,NULL,NULL,NULL,NULL,NULL,'active','2025-09-13 07:22:27','2025-09-13 07:22:27','Khadiza ','Khatun',0,NULL,NULL,NULL,NULL,'khadiza-khatun',NULL,NULL,0,0,NULL,1),
(8,'imranhoss57@gmail.com',NULL,NULL,'$2a$10$UgieVVaz7dNz83mnSMcx6eezoDfgOsWZHnYTeWugLD.vraBxcwkgu',NULL,5,1,NULL,NULL,NULL,NULL,NULL,'active','2025-09-13 07:32:52','2025-09-14 05:56:46','Munsi','Imran',0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0,NULL,1),
(9,'jamesbonadies75@gmail.com','',NULL,'$2a$10$7BoxWQbXhtJXanVtOnjEiO8PCOYftktUnN2LouDlIyW44RUfjoYoa',NULL,5,1,NULL,'/uploads/profile_photos/1757749110591-IMG-20250720-WA0592.jpg','','','','active','2025-09-13 07:34:19','2025-09-14 05:56:30','james','bonadies',0,'','',NULL,NULL,NULL,NULL,NULL,0,0,NULL,1),
(10,'mdrazuahamad8@gmail.com','',NULL,'$2a$10$Ge/6axfgIMkwcbsuLxHne.ASVi8YJBXzzXsMtaymuLsFlGl9QFd/q',NULL,2,1,NULL,'/uploads/profile_photos/1757749014484-MD Razu Ahamad 6.png','','','','active','2025-09-13 07:35:21','2025-09-13 13:21:30','MD. Razu','Ahamad',1,'','',NULL,NULL,'md-razu-ahamad',NULL,NULL,0,0,NULL,1),
(11,'abdullahalfarabiraju12345@gmail.com','',NULL,'$2a$10$wqeDh8ZfuUzwUo.1Arx/tuC9c4wv3lukJp8wzvP4hyy/DvecFQ8Ci',NULL,5,1,NULL,'/uploads/profile_photos/1757749336466-Razu passportSize.jpg','','','','active','2025-09-13 07:39:48','2025-09-13 12:58:26','Abdullah','AL Farabi',1,'','',NULL,NULL,NULL,NULL,NULL,0,0,NULL,1),
(12,'mollarihad@4gmail.com',NULL,NULL,'$2a$10$1KSJMYPqwK4QYeSSRmK6Ku2qY64CTCXCeAkKcqCuJ.xJJIt/Ph0Uq',NULL,5,1,NULL,NULL,NULL,NULL,NULL,'active','2025-09-13 07:56:53','2025-09-13 07:56:53','Rihad','Molla',0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0,NULL,1),
(13,'mollarihad4@gmail.com',NULL,NULL,'$2a$10$Tj69ZgFhTyxcNOj1OzwwnuRx83quzroixwdRPSv2p0fC21fRELaAO',NULL,5,1,NULL,NULL,NULL,NULL,NULL,'active','2025-09-13 07:57:47','2025-09-13 12:59:00','Rihad','Molla',0,NULL,NULL,'cus_T2uBj94Yh7mqCK',NULL,NULL,NULL,NULL,0,0,NULL,1),
(14,'abdullahalfarab345@gmail.com',NULL,NULL,'$2a$10$WKw3gRozI/b89nr7GeYA.uJ8mFzwiMngc0I/clot/Vy0uWXqB2o.K',NULL,5,1,NULL,NULL,NULL,NULL,NULL,'active','2025-09-13 08:19:39','2025-09-13 12:58:50','Razu ','AL Farabi',0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0,NULL,1),
(15,'nmuniru@yahoo.com',NULL,NULL,'$2a$10$Jw0h3ON8l0q8ZpmtZWNUuuQJE.Bf08c1rmkeZV11ULJh3iyaNvob.','2025-10-05 15:45:51',2,1,NULL,NULL,NULL,NULL,NULL,'active','2025-09-28 14:56:10','2025-10-05 16:55:40','Nashiru','Muniru',1,NULL,NULL,NULL,NULL,'nashiru-muniru',NULL,NULL,0,0,NULL,1),
(16,'cyklonesolutions@gmail.com',NULL,NULL,'$2a$10$n3sO9g0lPEsnHCxqkI0vReTxyYIoyW8g3Il1kT8RovzYlwxFG9YDW',NULL,2,1,NULL,NULL,NULL,NULL,NULL,'active','2025-09-28 15:25:15','2025-09-28 15:29:38','Anthony ','Ighomuaye',1,NULL,NULL,'cus_T8dpSiafW9gTJK',NULL,'anthony-ighomuaye',NULL,NULL,0,0,NULL,1),
(17,'Musengimana@gmail.com','',NULL,'$2a$10$SEVc1188fumoFTwxphbamehQyDvqeoIVTJoSWZIf60yXznErLLSeC',NULL,5,1,NULL,'/uploads/profile_photos/1760495525229_img_2926.jpg','','','','active','2025-09-28 17:26:47','2025-10-15 02:32:08','Normando','Musa',1,'','','cus_T8iWTQi6iNqG2g',NULL,NULL,NULL,NULL,0,0,NULL,1),
(18,'joshuawmabonga@gmail.com',NULL,NULL,'$2a$10$HuXSucVv9gDctmRPi8Ncvu9Mw3jvp2zMnMm/K3DBrluEjyxqG.oca',NULL,2,1,NULL,NULL,NULL,NULL,NULL,'active','2025-10-12 18:03:30','2025-10-12 18:12:57','Joshua','Wanyonyi',1,NULL,NULL,'cus_TDvcPLONw36bQV',NULL,'joshua-wanyonyi',NULL,NULL,0,0,NULL,1);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `v_admin_accounting_overview`
--

DROP TABLE IF EXISTS `v_admin_accounting_overview`;
/*!50001 DROP VIEW IF EXISTS `v_admin_accounting_overview`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8mb4;
/*!50001 CREATE VIEW `v_admin_accounting_overview` AS SELECT
 1 AS `currency`,
  1 AS `gross_sales_net_expert`,
  1 AS `payouts_paid`,
  1 AS `total_fees_collected`,
  1 AS `platform_liability_pending`,
  1 AS `platform_liability_available`,
  1 AS `platform_liability_reserved` */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `v_user_orders`
--

DROP TABLE IF EXISTS `v_user_orders`;
/*!50001 DROP VIEW IF EXISTS `v_user_orders`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8mb4;
/*!50001 CREATE VIEW `v_user_orders` AS SELECT
 1 AS `order_id`,
  1 AS `user_id`,
  1 AS `kind`,
  1 AS `ref_id`,
  1 AS `amount_cents`,
  1 AS `currency`,
  1 AS `status`,
  1 AS `description`,
  1 AS `created_at`,
  1 AS `last_payment_at` */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `vw_chat_last_message`
--

DROP TABLE IF EXISTS `vw_chat_last_message`;
/*!50001 DROP VIEW IF EXISTS `vw_chat_last_message`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8mb4;
/*!50001 CREATE VIEW `vw_chat_last_message` AS SELECT
 1 AS `chat_id`,
  1 AS `last_message_id`,
  1 AS `sender_id`,
  1 AS `content`,
  1 AS `file_url`,
  1 AS `attachment`,
  1 AS `last_message_at` */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `vw_user_chat_unread`
--

DROP TABLE IF EXISTS `vw_user_chat_unread`;
/*!50001 DROP VIEW IF EXISTS `vw_user_chat_unread`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8mb4;
/*!50001 CREATE VIEW `vw_user_chat_unread` AS SELECT
 1 AS `user_id`,
  1 AS `chat_id`,
  1 AS `unread_count` */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `wallet_ledger`
--

DROP TABLE IF EXISTS `wallet_ledger`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `wallet_ledger` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) unsigned NOT NULL,
  `role` enum('expert','platform','user') NOT NULL DEFAULT 'expert',
  `kind` enum('EARN','HOLD_RELEASED','RESERVE','PAYOUT_RESERVE','PAYOUT_REQUEST','PAYOUT_APPROVED','PAYOUT_REJECTED','PAYOUT_PAID','ADJUST') NOT NULL,
  `amount` decimal(12,2) NOT NULL,
  `currency` char(3) NOT NULL DEFAULT 'USD',
  `description` varchar(255) DEFAULT NULL,
  `available_at` datetime DEFAULT NULL,
  `ref_table` varchar(64) DEFAULT NULL,
  `ref_id` bigint(20) DEFAULT NULL,
  `ref_desc` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_dedupe` (`user_id`,`kind`,`ref_table`,`ref_id`),
  KEY `k_user_kind_time` (`user_id`,`kind`,`created_at`)
) ENGINE=InnoDB AUTO_INCREMENT=97 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `wallet_ledger`
--

LOCK TABLES `wallet_ledger` WRITE;
/*!40000 ALTER TABLE `wallet_ledger` DISABLE KEYS */;
INSERT INTO `wallet_ledger` VALUES
(1,3,'expert','EARN',17.11,'USD',NULL,'2025-08-18 12:00:00','service_orders',5,'Service order','2025-09-07 20:20:28'),
(2,3,'expert','EARN',43.24,'USD',NULL,'2025-08-15 12:00:00','service_orders',6,'Service order','2025-09-07 20:20:28'),
(3,3,'expert','EARN',17.11,'USD',NULL,'2025-08-15 14:00:00','service_orders',36,'Service order','2025-09-07 20:20:28'),
(4,3,'expert','EARN',17.11,'USD',NULL,'2025-08-15 15:00:00','service_orders',39,'Service order','2025-09-07 20:20:28'),
(5,3,'expert','EARN',8.41,'USD',NULL,'2025-08-20 11:00:00','service_orders',41,'Service order','2025-09-07 20:20:28'),
(6,3,'expert','EARN',17.11,'USD',NULL,'2025-09-03 11:00:00','service_orders',50,'Service order','2025-09-07 20:20:28'),
(7,3,'expert','EARN',8.41,'USD',NULL,'2025-09-08 13:00:00','service_orders',53,'Service order','2025-09-07 20:20:28'),
(8,3,'expert','EARN',8.41,'USD',NULL,'2025-09-10 11:00:00','service_orders',55,'Service order','2025-09-07 20:20:28'),
(9,3,'expert','EARN',24.96,'USD',NULL,'2025-09-10 12:00:00','service_orders',56,'Service order','2025-09-07 20:20:28'),
(10,3,'expert','EARN',17.12,'USD',NULL,'2025-08-26 18:21:16','course_orders',1,'Course order','2025-09-07 20:20:29'),
(11,1,'expert','EARN',17.12,'USD',NULL,'2025-09-14 23:39:59','course_orders',5,'Course order','2025-09-07 20:20:29'),
(12,3,'expert','EARN',17.12,'USD',NULL,'2025-09-14 22:38:50','course_orders',7,'Course order','2025-09-07 20:20:29'),
(13,3,'expert','EARN',42.38,'USD',NULL,'2025-09-14 22:03:58','course_orders',13,'Course order','2025-09-07 20:20:29'),
(14,3,'expert','EARN',17.12,'USD',NULL,'2025-09-08 13:35:08','coaching_orders',6,'Coaching order','2025-09-07 20:20:29'),
(15,3,'expert','EARN',17.12,'USD',NULL,'2025-09-08 13:23:49','coaching_orders',7,'Coaching order','2025-09-07 20:20:29'),
(16,3,'expert','EARN',17.12,'USD',NULL,'2025-09-09 00:50:48','coaching_orders',9,'Coaching order','2025-09-07 20:20:29'),
(17,3,'expert','EARN',17.12,'USD',NULL,'2025-09-08 23:24:04','coaching_orders',10,'Coaching order','2025-09-07 20:20:29'),
(18,3,'expert','EARN',17.12,'USD',NULL,'2025-09-08 22:01:42','coaching_orders',11,'Coaching order','2025-09-07 20:20:29'),
(19,3,'expert','EARN',17.12,'USD',NULL,'2025-09-09 00:00:28','coaching_orders',13,'Coaching order','2025-09-07 20:20:29'),
(20,3,'expert','EARN',17.12,'USD',NULL,'2025-09-14 14:45:16','coaching_orders',15,'Coaching order','2025-09-07 20:20:29'),
(45,3,'expert','PAYOUT_REQUEST',25.00,'USD',NULL,NULL,'payout_requests',6,NULL,'2025-09-07 20:59:03'),
(47,3,'expert','PAYOUT_REQUEST',20.00,'USD',NULL,NULL,'payout_requests',7,NULL,'2025-09-07 21:16:04'),
(48,3,'expert','PAYOUT_RESERVE',20.00,'USD',NULL,NULL,'payout_requests',7,NULL,'2025-09-07 21:16:04'),
(49,3,'expert','PAYOUT_APPROVED',20.00,'USD',NULL,NULL,'payout_requests',7,NULL,'2025-09-07 21:18:55'),
(51,3,'expert','PAYOUT_PAID',19.12,'USD',NULL,NULL,'payout_requests',7,NULL,'2025-09-07 21:23:27'),
(52,3,'expert','ADJUST',0.88,'USD',NULL,NULL,'payout_requests',7,NULL,'2025-09-07 21:23:27'),
(74,3,'expert','PAYOUT_REQUEST',30.00,'USD',NULL,NULL,'payout_requests',8,NULL,'2025-09-07 21:59:19'),
(75,3,'expert','PAYOUT_RESERVE',30.00,'USD',NULL,NULL,'payout_requests',8,NULL,'2025-09-07 21:59:19'),
(76,3,'expert','PAYOUT_APPROVED',30.00,'USD',NULL,NULL,'payout_requests',8,NULL,'2025-09-07 22:00:02'),
(77,3,'expert','PAYOUT_PAID',30.00,'USD',NULL,NULL,'payout_requests',8,NULL,'2025-09-07 22:01:47'),
(78,3,'expert','PAYOUT_REQUEST',20.00,'USD',NULL,NULL,'payout_requests',9,NULL,'2025-09-12 05:37:01'),
(79,3,'expert','PAYOUT_RESERVE',20.00,'USD',NULL,NULL,'payout_requests',9,NULL,'2025-09-12 05:37:01'),
(80,3,'expert','PAYOUT_APPROVED',20.00,'USD',NULL,NULL,'payout_requests',9,NULL,'2025-09-12 06:56:16'),
(81,3,'expert','PAYOUT_PAID',19.02,'USD',NULL,NULL,'payout_requests',9,NULL,'2025-09-12 06:56:40'),
(82,3,'expert','ADJUST',0.98,'USD',NULL,NULL,'payout_requests',9,NULL,'2025-09-12 06:56:40'),
(83,3,'expert','EARN',8.81,'USD',NULL,'2025-09-20 08:03:51','service_orders',58,'Service order','2025-09-13 08:03:51'),
(84,3,'expert','PAYOUT_REQUEST',50.00,'USD',NULL,NULL,'payout_requests',10,NULL,'2025-09-13 14:29:10'),
(85,3,'expert','PAYOUT_RESERVE',50.00,'USD',NULL,NULL,'payout_requests',10,NULL,'2025-09-13 14:29:10'),
(86,3,'expert','PAYOUT_APPROVED',50.00,'USD',NULL,NULL,'payout_requests',10,NULL,'2025-09-13 14:35:42'),
(87,3,'expert','PAYOUT_PAID',48.65,'USD',NULL,NULL,'payout_requests',10,NULL,'2025-09-13 14:37:09'),
(88,3,'expert','ADJUST',1.35,'USD',NULL,NULL,'payout_requests',10,NULL,'2025-09-13 14:37:09'),
(89,6,'expert','EARN',97.23,'USD',NULL,'2025-09-21 07:25:21','service_orders',59,'Service order','2025-09-14 07:25:21'),
(90,6,'expert','EARN',97.23,'USD',NULL,'2025-09-21 07:38:04','service_orders',60,'Service order','2025-09-14 07:38:04'),
(91,3,'expert','EARN',390.10,'USD',NULL,'2025-10-04 09:21:27','service_orders',63,'Service order','2025-09-27 09:21:27'),
(92,6,'expert','EARN',1.94,'USD',NULL,'2025-10-05 20:00:00','service_orders',67,'Service order','2025-09-28 18:28:22'),
(93,6,'expert','EARN',1.94,'USD',NULL,'2025-10-05 21:00:00','service_orders',68,'Service order','2025-09-28 18:37:40'),
(94,3,'expert','PAYOUT_REQUEST',30.00,'USD',NULL,NULL,'payout_requests',11,NULL,'2025-10-05 07:34:09'),
(95,3,'expert','PAYOUT_RESERVE',30.00,'USD',NULL,NULL,'payout_requests',11,NULL,'2025-10-05 07:34:09'),
(96,6,'expert','EARN',1.94,'USD',NULL,'2025-10-19 11:00:00','service_orders',70,'Service order','2025-10-05 16:28:28');
/*!40000 ALTER TABLE `wallet_ledger` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Final view structure for view `v_admin_accounting_overview`
--

/*!50001 DROP VIEW IF EXISTS `v_admin_accounting_overview`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_admin_accounting_overview` AS select (select `accounting_settings`.`currency` from `accounting_settings` where `accounting_settings`.`id` = 1) AS `currency`,coalesce((select sum(case when `wallet_ledger`.`kind` = 'EARN' then `wallet_ledger`.`amount` else 0 end) from `wallet_ledger`),0) AS `gross_sales_net_expert`,coalesce((select sum(case when `wallet_ledger`.`kind` = 'WITHDRAWAL' then `wallet_ledger`.`amount` else 0 end) from `wallet_ledger`),0) AS `payouts_paid`,coalesce((select sum(case when `wallet_ledger`.`kind` = 'FEE' and `wallet_ledger`.`role` = 'platform' then `wallet_ledger`.`amount` else 0 end) from `wallet_ledger`),0) AS `total_fees_collected`,coalesce((select sum(case when `wallet_ledger`.`kind` = 'EARN' and (`wallet_ledger`.`available_at` is null or `wallet_ledger`.`available_at` > current_timestamp()) then `wallet_ledger`.`amount` else 0 end) from `wallet_ledger`),0) AS `platform_liability_pending`,coalesce((select sum(case when `wallet_ledger`.`kind` = 'EARN' and `wallet_ledger`.`available_at` is not null and `wallet_ledger`.`available_at` <= current_timestamp() then `wallet_ledger`.`amount` else 0 end) - (select coalesce(sum(case when `wallet_ledger`.`kind` = 'RESERVE' then `wallet_ledger`.`amount` when `wallet_ledger`.`kind` = 'UNRESERVE' then -`wallet_ledger`.`amount` else 0 end),0) from `wallet_ledger`) - (select coalesce(sum(case when `wallet_ledger`.`kind` = 'WITHDRAWAL' then `wallet_ledger`.`amount` else 0 end),0) from `wallet_ledger`) from `wallet_ledger`),0) AS `platform_liability_available`,coalesce((select sum(case when `wallet_ledger`.`kind` = 'RESERVE' then `wallet_ledger`.`amount` when `wallet_ledger`.`kind` = 'UNRESERVE' then -`wallet_ledger`.`amount` else 0 end) from `wallet_ledger`),0) AS `platform_liability_reserved` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_user_orders`
--

/*!50001 DROP VIEW IF EXISTS `v_user_orders`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_user_orders` AS select `o`.`id` AS `order_id`,`o`.`user_id` AS `user_id`,`o`.`kind` AS `kind`,`o`.`ref_id` AS `ref_id`,`o`.`amount_cents` AS `amount_cents`,`o`.`currency` AS `currency`,`o`.`status` AS `status`,`o`.`description` AS `description`,`o`.`created_at` AS `created_at`,max(`op`.`created_at`) AS `last_payment_at` from (`orders` `o` left join `order_payments` `op` on(`op`.`order_id` = `o`.`id`)) group by `o`.`id` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_chat_last_message`
--

/*!50001 DROP VIEW IF EXISTS `vw_chat_last_message`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_chat_last_message` AS select `m`.`chat_id` AS `chat_id`,`m`.`id` AS `last_message_id`,`m`.`sender_id` AS `sender_id`,`m`.`content` AS `content`,`m`.`file_url` AS `file_url`,`m`.`attachment` AS `attachment`,`m`.`created_at` AS `last_message_at` from (`messages` `m` join (select `messages`.`chat_id` AS `chat_id`,max(`messages`.`created_at`) AS `max_created` from `messages` group by `messages`.`chat_id`) `t` on(`t`.`chat_id` = `m`.`chat_id` and `t`.`max_created` = `m`.`created_at`)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_user_chat_unread`
--

/*!50001 DROP VIEW IF EXISTS `vw_user_chat_unread`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_user_chat_unread` AS select `cp`.`user_id` AS `user_id`,`m`.`chat_id` AS `chat_id`,count(0) AS `unread_count` from ((`chat_participants` `cp` join `messages` `m` on(`m`.`chat_id` = `cp`.`chat_id` and `m`.`sender_id` <> `cp`.`user_id`)) left join `message_reads` `mr` on(`mr`.`message_id` = `m`.`id` and `mr`.`user_id` = `cp`.`user_id`)) where `mr`.`message_id` is null group by `cp`.`user_id`,`m`.`chat_id` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-10-17 13:08:35
