/*
VEDANTU CLASS ENGAGEMENT & OPERATIONS ANALYTICS
MySQL Portfolio Project

Business definition:
Engagement = students staying >= 45 minutes / students joined
Target = 25%

Validated KPIs:
720 classes | 550,385 joined | 140,664 engaged
25.56% engagement | 382 target-achieved | 53.06% target achievement
72.07% attendance | 3.62 average rating | 18.15% rating response
81.94% SLA compliance

Use observed/association language in portfolio findings; these queries do not establish causation.
*/

CREATE DATABASE IF NOT EXISTS vedantu_analytics;
USE vedantu_analytics;

/* 01 - KPI ANALYSIS */
SELECT COUNT(*) AS total_classes,
       SUM(StudentRegistrations) AS student_registrations,
       SUM(StudentsJoined) AS students_joined,
       SUM(StudentsCompleted) AS students_engaged,
       ROUND(SUM(StudentsCompleted)/SUM(StudentsJoined)*100,2) AS engagement_rate,
       SUM(CASE WHEN EngagementRate >= 0.25 THEN 1 ELSE 0 END) AS target_achieved_classes,
       ROUND(SUM(CASE WHEN EngagementRate >= 0.25 THEN 1 ELSE 0 END)/COUNT(*)*100,2) AS target_achievement_rate,
       ROUND(SUM(StudentsJoined)/SUM(StudentRegistrations)*100,2) AS attendance_rate,
       ROUND(AVG(OverallRating),2) AS average_rating,
       ROUND(SUM(RatingResponses)/SUM(StudentsJoined)*100,2) AS rating_response_rate
FROM classes;

SELECT COUNT(*) AS total_classes,
       SUM(CASE WHEN Overall_SLA='Met' THEN 1 ELSE 0 END) AS sla_met,
       SUM(CASE WHEN Overall_SLA='Breached' THEN 1 ELSE 0 END) AS sla_breached,
       ROUND(SUM(CASE WHEN Overall_SLA='Met' THEN 1 ELSE 0 END)/COUNT(*)*100,2) AS sla_compliance_rate
FROM classoperations;

/* 02 - SUBJECT ANALYSIS */
SELECT s.Subject,
       COUNT(c.ClassID) AS total_classes,
       SUM(c.StudentsJoined) AS students_joined,
       SUM(c.StudentsCompleted) AS students_engaged,
       ROUND(SUM(c.StudentsCompleted)/SUM(c.StudentsJoined)*100,2) AS engagement_rate,
       SUM(CASE WHEN c.EngagementRate >= 0.25 THEN 1 ELSE 0 END) AS target_achieved_classes,
       SUM(CASE WHEN c.EngagementRate < 0.25 THEN 1 ELSE 0 END) AS below_target_classes,
       ROUND(SUM(CASE WHEN c.EngagementRate >= 0.25 THEN 1 ELSE 0 END)/COUNT(*)*100,2) AS target_achievement_rate
FROM classes c JOIN subjects s ON c.SubjectID=s.SubjectID
GROUP BY s.Subject ORDER BY engagement_rate DESC;

/* 03 - TOPIC ANALYSIS */
SELECT s.Subject,t.Topic,COUNT(c.ClassID) AS total_classes,
       SUM(c.StudentsJoined) AS students_joined,
       SUM(c.StudentsCompleted) AS students_engaged,
       ROUND(SUM(c.StudentsCompleted)/SUM(c.StudentsJoined)*100,2) AS engagement_rate
FROM classes c JOIN topics t ON c.TopicID=t.TopicID JOIN subjects s ON t.SubjectID=s.SubjectID
GROUP BY s.Subject,t.Topic ORDER BY engagement_rate DESC;

SELECT s.Subject,t.Topic,COUNT(c.ClassID) AS total_classes,
       ROUND(SUM(c.StudentsCompleted)/SUM(c.StudentsJoined)*100,2) AS engagement_rate
FROM classes c JOIN topics t ON c.TopicID=t.TopicID JOIN subjects s ON t.SubjectID=s.SubjectID
GROUP BY s.Subject,t.Topic ORDER BY engagement_rate DESC LIMIT 10;

SELECT s.Subject,t.Topic,COUNT(c.ClassID) AS total_classes,
       ROUND(SUM(c.StudentsCompleted)/SUM(c.StudentsJoined)*100,2) AS engagement_rate
FROM classes c JOIN topics t ON c.TopicID=t.TopicID JOIN subjects s ON t.SubjectID=s.SubjectID
GROUP BY s.Subject,t.Topic ORDER BY engagement_rate ASC LIMIT 10;

/* 04 - TEACHER ANALYSIS */
SELECT t.TeacherID,t.Teacher,s.Subject,COUNT(c.ClassID) AS total_classes,
       SUM(c.StudentsJoined) AS students_joined,SUM(c.StudentsCompleted) AS students_engaged,
       ROUND(SUM(c.StudentsCompleted)/SUM(c.StudentsJoined)*100,2) AS engagement_rate
FROM classes c JOIN teachers t ON c.TeacherID=t.TeacherID JOIN subjects s ON t.SubjectID=s.SubjectID
GROUP BY t.TeacherID,t.Teacher,s.Subject ORDER BY engagement_rate DESC;

SELECT t.TeacherID,t.Teacher,s.Subject,COUNT(c.ClassID) AS total_classes,
       ROUND(SUM(c.StudentsCompleted)/SUM(c.StudentsJoined)*100,2) AS engagement_rate,
       SUM(CASE WHEN c.EngagementRate>=0.25 THEN 1 ELSE 0 END) AS target_achieved_classes,
       SUM(CASE WHEN c.EngagementRate<0.25 THEN 1 ELSE 0 END) AS below_target_classes,
       ROUND(SUM(CASE WHEN c.EngagementRate>=0.25 THEN 1 ELSE 0 END)/COUNT(*)*100,2) AS target_achievement_rate
FROM classes c JOIN teachers t ON c.TeacherID=t.TeacherID JOIN subjects s ON t.SubjectID=s.SubjectID
GROUP BY t.TeacherID,t.Teacher,s.Subject ORDER BY engagement_rate DESC;

SELECT t.TeacherID,t.Teacher,s.Subject,COUNT(c.ClassID) AS total_classes,
       ROUND(SUM(c.StudentsCompleted)/SUM(c.StudentsJoined)*100,2) AS engagement_rate,
       ROUND(AVG(c.TeacherRating),2) AS avg_teacher_rating,
       ROUND(AVG(c.InteractionRating),2) AS avg_interaction_rating,
       ROUND(AVG(c.OverallRating),2) AS avg_overall_rating
FROM classes c JOIN teachers t ON c.TeacherID=t.TeacherID JOIN subjects s ON t.SubjectID=s.SubjectID
GROUP BY t.TeacherID,t.Teacher,s.Subject HAVING COUNT(*)>=5 ORDER BY engagement_rate DESC;

SELECT t.TeacherID,t.Teacher,s.Subject,COUNT(c.ClassID) AS total_classes,
       SUM(CASE WHEN c.EngagementRate<0.25 THEN 1 ELSE 0 END) AS below_target_classes,
       ROUND(SUM(CASE WHEN c.EngagementRate<0.25 THEN 1 ELSE 0 END)/COUNT(*)*100,2) AS below_target_rate
FROM classes c JOIN teachers t ON c.TeacherID=t.TeacherID JOIN subjects s ON t.SubjectID=s.SubjectID
GROUP BY t.TeacherID,t.Teacher,s.Subject HAVING COUNT(*)>=5 ORDER BY below_target_rate DESC;

/* 05 - PROMOTIONAL STRATEGY */
SELECT p.Strategy,COUNT(c.ClassID) AS total_classes,
       SUM(c.StudentsJoined) AS students_joined,SUM(c.StudentsCompleted) AS students_engaged,
       ROUND(SUM(c.StudentsCompleted)/SUM(c.StudentsJoined)*100,2) AS engagement_rate,
       SUM(CASE WHEN c.EngagementRate>=0.25 THEN 1 ELSE 0 END) AS target_achieved_classes,
       SUM(CASE WHEN c.EngagementRate<0.25 THEN 1 ELSE 0 END) AS below_target_classes,
       ROUND(SUM(CASE WHEN c.EngagementRate>=0.25 THEN 1 ELSE 0 END)/COUNT(*)*100,2) AS target_achievement_rate
FROM classes c JOIN promotionalstrategies p ON c.PromotionalStrategyID=p.StrategyID
GROUP BY p.Strategy,p.StrategyID ORDER BY engagement_rate DESC;

SELECT p.Strategy,COUNT(c.ClassID) AS total_classes,
       SUM(c.StudentsJoined) AS students_joined,SUM(c.StudentsCompleted) AS students_engaged,
       ROUND(SUM(c.StudentsCompleted)/SUM(c.StudentsJoined)*100,2) AS engagement_rate
FROM classes c JOIN promotionalstrategies p ON c.PromotionalStrategyID=p.StrategyID
WHERE p.Strategy IN ('Gift Box','Standard Promotion') GROUP BY p.Strategy ORDER BY engagement_rate DESC;

SELECT s.Subject,p.Strategy,COUNT(c.ClassID) AS total_classes,
       SUM(c.StudentsJoined) AS students_joined,SUM(c.StudentsCompleted) AS students_engaged,
       ROUND(SUM(c.StudentsCompleted)/SUM(c.StudentsJoined)*100,2) AS engagement_rate
FROM classes c JOIN subjects s ON c.SubjectID=s.SubjectID JOIN promotionalstrategies p ON c.PromotionalStrategyID=p.StrategyID
WHERE p.Strategy IN ('Gift Box','Standard Promotion')
GROUP BY s.Subject,p.Strategy ORDER BY s.Subject,engagement_rate DESC;

/* 06 - RETENTION */
SELECT p.Strategy,COUNT(e.ClassID) AS total_classes,
       SUM(e.StudentsJoined) AS students_joined,SUM(e.Stayed_15Min) AS stayed_15_min,
       SUM(e.Stayed_30Min) AS stayed_30_min,SUM(e.Stayed_45Min) AS stayed_45_min,SUM(e.Stayed_60Min) AS stayed_60_min,
       ROUND(SUM(e.Stayed_15Min)/SUM(e.StudentsJoined)*100,2) AS retention_15_min,
       ROUND(SUM(e.Stayed_30Min)/SUM(e.StudentsJoined)*100,2) AS retention_30_min,
       ROUND(SUM(e.Stayed_45Min)/SUM(e.StudentsJoined)*100,2) AS retention_45_min,
       ROUND(SUM(e.Stayed_60Min)/SUM(e.StudentsJoined)*100,2) AS retention_60_min
FROM engagementmilestones e JOIN classes c ON e.ClassID=c.ClassID JOIN promotionalstrategies p ON c.PromotionalStrategyID=p.StrategyID
GROUP BY p.Strategy,p.StrategyID ORDER BY retention_45_min DESC;

SELECT p.Strategy,COUNT(e.ClassID) AS total_classes,
       ROUND(SUM(e.Stayed_30Min)/SUM(e.StudentsJoined)*100,2) AS retention_30_min,
       ROUND(SUM(e.Stayed_45Min)/SUM(e.StudentsJoined)*100,2) AS retention_45_min,
       ROUND(SUM(e.Stayed_45Min)/SUM(e.Stayed_30Min)*100,2) AS conversion_30_to_45
FROM engagementmilestones e JOIN classes c ON e.ClassID=c.ClassID JOIN promotionalstrategies p ON c.PromotionalStrategyID=p.StrategyID
GROUP BY p.Strategy,p.StrategyID ORDER BY conversion_30_to_45 DESC;

SELECT SUM(StudentsJoined) AS students_joined,SUM(Stayed_15Min) AS stayed_15_min,
       SUM(Stayed_30Min) AS stayed_30_min,SUM(Stayed_45Min) AS stayed_45_min,SUM(Stayed_60Min) AS stayed_60_min,
       ROUND(SUM(Stayed_15Min)/SUM(StudentsJoined)*100,2) AS retention_15_min,
       ROUND(SUM(Stayed_30Min)/SUM(StudentsJoined)*100,2) AS retention_30_min,
       ROUND(SUM(Stayed_45Min)/SUM(StudentsJoined)*100,2) AS retention_45_min,
       ROUND(SUM(Stayed_60Min)/SUM(StudentsJoined)*100,2) AS retention_60_min
FROM engagementmilestones;

SELECT ROUND((1-SUM(Stayed_15Min)/SUM(StudentsJoined))*100,2) AS dropoff_joined_to_15min,
       ROUND((1-SUM(Stayed_30Min)/SUM(Stayed_15Min))*100,2) AS dropoff_15_to_30min,
       ROUND((1-SUM(Stayed_45Min)/SUM(Stayed_30Min))*100,2) AS dropoff_30_to_45min,
       ROUND((1-SUM(Stayed_60Min)/SUM(Stayed_45Min))*100,2) AS dropoff_45_to_60min
FROM engagementmilestones;

/* 07 - ROOT CAUSE / RATINGS */
SELECT CASE WHEN EngagementRate>=0.25 THEN 'Target Achieved' ELSE 'Below Target' END AS performance_group,
       COUNT(ClassID) AS total_classes,
       ROUND(AVG(TeacherRating),2) AS avg_teacher_rating,
       ROUND(AVG(ContentRating),2) AS avg_content_rating,
       ROUND(AVG(TopicRelevanceRating),2) AS avg_topic_relevance_rating,
       ROUND(AVG(InteractionRating),2) AS avg_interaction_rating,
       ROUND(AVG(PromotionRating),2) AS avg_promotion_rating,
       ROUND(AVG(OverallRating),2) AS avg_overall_rating
FROM classes
GROUP BY CASE WHEN EngagementRate>=0.25 THEN 'Target Achieved' ELSE 'Below Target' END;

SELECT ROUND(AVG(CASE WHEN EngagementRate>=0.25 THEN TeacherRating END)-AVG(CASE WHEN EngagementRate<0.25 THEN TeacherRating END),2) AS teacher_rating_gap,
       ROUND(AVG(CASE WHEN EngagementRate>=0.25 THEN ContentRating END)-AVG(CASE WHEN EngagementRate<0.25 THEN ContentRating END),2) AS content_rating_gap,
       ROUND(AVG(CASE WHEN EngagementRate>=0.25 THEN TopicRelevanceRating END)-AVG(CASE WHEN EngagementRate<0.25 THEN TopicRelevanceRating END),2) AS topic_relevance_gap,
       ROUND(AVG(CASE WHEN EngagementRate>=0.25 THEN InteractionRating END)-AVG(CASE WHEN EngagementRate<0.25 THEN InteractionRating END),2) AS interaction_rating_gap,
       ROUND(AVG(CASE WHEN EngagementRate>=0.25 THEN PromotionRating END)-AVG(CASE WHEN EngagementRate<0.25 THEN PromotionRating END),2) AS promotion_rating_gap,
       ROUND(AVG(CASE WHEN EngagementRate>=0.25 THEN OverallRating END)-AVG(CASE WHEN EngagementRate<0.25 THEN OverallRating END),2) AS overall_rating_gap
FROM classes;

SELECT CASE WHEN EngagementRate<0.20 THEN 'Below 20%' WHEN EngagementRate<0.25 THEN '20–24.9%' WHEN EngagementRate<0.30 THEN '25–29.9%' ELSE '30%+' END AS engagement_bucket,
       COUNT(ClassID) AS total_classes,
       ROUND(AVG(TeacherRating),2) AS avg_teacher_rating,
       ROUND(AVG(ContentRating),2) AS avg_content_rating,
       ROUND(AVG(TopicRelevanceRating),2) AS avg_topic_relevance_rating,
       ROUND(AVG(InteractionRating),2) AS avg_interaction_rating,
       ROUND(AVG(PromotionRating),2) AS avg_promotion_rating,
       ROUND(AVG(OverallRating),2) AS avg_overall_rating
FROM classes
GROUP BY CASE WHEN EngagementRate<0.20 THEN 'Below 20%' WHEN EngagementRate<0.25 THEN '20–24.9%' WHEN EngagementRate<0.30 THEN '25–29.9%' ELSE '30%+' END
ORDER BY CASE WHEN engagement_bucket='Below 20%' THEN 1 WHEN engagement_bucket='20–24.9%' THEN 2 WHEN engagement_bucket='25–29.9%' THEN 3 ELSE 4 END;

SELECT c.ClassID,c.ClassDate,s.Subject,t.Topic,tr.Teacher,p.Strategy,
       ROUND(c.EngagementRate*100,2) AS engagement_rate,
       ROUND(c.TeacherRating,2) AS teacher_rating,ROUND(c.ContentRating,2) AS content_rating,
       ROUND(c.TopicRelevanceRating,2) AS topic_relevance_rating,ROUND(c.InteractionRating,2) AS interaction_rating,
       ROUND(c.PromotionRating,2) AS promotion_rating,ROUND(c.OverallRating,2) AS overall_rating,c.DeepDiveRequired
FROM classes c JOIN subjects s ON c.SubjectID=s.SubjectID JOIN topics t ON c.TopicID=t.TopicID
JOIN teachers tr ON c.TeacherID=tr.TeacherID JOIN promotionalstrategies p ON c.PromotionalStrategyID=p.StrategyID
WHERE c.EngagementRate<0.25 ORDER BY c.EngagementRate ASC;

/* 08 - OPERATIONS / SLA */
SELECT CASE WHEN c.EngagementRate>=0.25 THEN 'Target Achieved' ELSE 'Below Target' END AS performance_group,
       COUNT(c.ClassID) AS total_classes,
       SUM(CASE WHEN co.Overall_SLA='Met' THEN 1 ELSE 0 END) AS sla_compliant_classes,
       SUM(CASE WHEN co.Overall_SLA='Breached' THEN 1 ELSE 0 END) AS sla_non_compliant_classes,
       ROUND(SUM(CASE WHEN co.Overall_SLA='Met' THEN 1 ELSE 0 END)/COUNT(*)*100,2) AS sla_compliance_rate
FROM classes c JOIN classoperations co ON c.ClassID=co.ClassID
GROUP BY CASE WHEN c.EngagementRate>=0.25 THEN 'Target Achieved' ELSE 'Below Target' END;

SELECT s.Subject,COUNT(c.ClassID) AS total_classes,
       SUM(CASE WHEN co.Overall_SLA='Met' THEN 1 ELSE 0 END) AS sla_met,
       SUM(CASE WHEN co.Overall_SLA='Breached' THEN 1 ELSE 0 END) AS sla_breached,
       ROUND(SUM(CASE WHEN co.Overall_SLA='Breached' THEN 1 ELSE 0 END)/COUNT(*)*100,2) AS sla_breach_rate
FROM classes c JOIN subjects s ON c.SubjectID=s.SubjectID JOIN classoperations co ON c.ClassID=co.ClassID
GROUP BY s.Subject ORDER BY sla_breach_rate DESC;

SELECT COUNT(c.ClassID) AS below_target_classes,
       SUM(CASE WHEN co.Overall_SLA='Breached' THEN 1 ELSE 0 END) AS sla_breached_classes,
       SUM(CASE WHEN co.Overall_SLA='Met' THEN 1 ELSE 0 END) AS sla_met_classes,
       ROUND(SUM(CASE WHEN co.Overall_SLA='Breached' THEN 1 ELSE 0 END)/COUNT(*)*100,2) AS breach_rate
FROM classes c JOIN classoperations co ON c.ClassID=co.ClassID WHERE c.EngagementRate<0.25;

SELECT 'SME SLA' AS sla_type,
       SUM(CASE WHEN SME_SLA='Breached' THEN 1 ELSE 0 END) AS breached_classes,
       ROUND(SUM(CASE WHEN SME_SLA='Breached' THEN 1 ELSE 0 END)/COUNT(*)*100,2) AS breach_rate
FROM classoperations
UNION ALL
SELECT 'Deck SLA',SUM(CASE WHEN Deck_SLA='Breached' THEN 1 ELSE 0 END),
       ROUND(SUM(CASE WHEN Deck_SLA='Breached' THEN 1 ELSE 0 END)/COUNT(*)*100,2)
FROM classoperations;

SELECT c.ClassID,c.ClassDate,s.Subject,t.Topic,tr.Teacher,p.Strategy,
       ROUND(c.EngagementRate*100,2) AS engagement_rate,
       co.SME_SLA,co.Deck_SLA,co.Overall_SLA,c.DeepDiveRequired,
       ROUND(c.TeacherRating,2) AS teacher_rating,ROUND(c.ContentRating,2) AS content_rating,
       ROUND(c.InteractionRating,2) AS interaction_rating,ROUND(c.TopicRelevanceRating,2) AS topic_relevance_rating,
       ROUND(c.PromotionRating,2) AS promotion_rating
FROM classes c JOIN subjects s ON c.SubjectID=s.SubjectID JOIN topics t ON c.TopicID=t.TopicID
JOIN teachers tr ON c.TeacherID=tr.TeacherID JOIN promotionalstrategies p ON c.PromotionalStrategyID=p.StrategyID
JOIN classoperations co ON c.ClassID=co.ClassID
WHERE c.EngagementRate<0.25 AND co.Overall_SLA='Breached' AND c.DeepDiveRequired='Yes'
ORDER BY c.EngagementRate ASC;

/* 09 - TIME ANALYSIS */
SELECT c.MonthNumber,c.Month,COUNT(c.ClassID) AS total_classes,
       SUM(c.StudentsJoined) AS students_joined,SUM(c.StudentsCompleted) AS students_engaged,
       ROUND(SUM(c.StudentsCompleted)/SUM(c.StudentsJoined)*100,2) AS engagement_rate,
       SUM(CASE WHEN c.EngagementRate>=0.25 THEN 1 ELSE 0 END) AS target_achieved_classes,
       SUM(CASE WHEN c.EngagementRate<0.25 THEN 1 ELSE 0 END) AS below_target_classes,
       ROUND(SUM(CASE WHEN c.EngagementRate>=0.25 THEN 1 ELSE 0 END)/COUNT(*)*100,2) AS target_achievement_rate
FROM classes c GROUP BY c.MonthNumber,c.Month ORDER BY c.MonthNumber;

SELECT c.MonthNumber,c.Month,COUNT(c.ClassID) AS total_classes,
       SUM(CASE WHEN co.Overall_SLA='Met' THEN 1 ELSE 0 END) AS sla_met,
       SUM(CASE WHEN co.Overall_SLA='Breached' THEN 1 ELSE 0 END) AS sla_breached,
       ROUND(SUM(CASE WHEN co.Overall_SLA='Met' THEN 1 ELSE 0 END)/COUNT(*)*100,2) AS sla_compliance_rate
FROM classes c JOIN classoperations co ON c.ClassID=co.ClassID
GROUP BY c.MonthNumber,c.Month ORDER BY c.MonthNumber;

SELECT CASE WHEN IsWeekend='True' THEN 'Weekend' ELSE 'Weekday' END AS class_day_type,
       COUNT(ClassID) AS total_classes,SUM(StudentsJoined) AS students_joined,SUM(StudentsCompleted) AS students_engaged,
       ROUND(SUM(StudentsCompleted)/SUM(StudentsJoined)*100,2) AS engagement_rate,
       SUM(CASE WHEN EngagementRate>=0.25 THEN 1 ELSE 0 END) AS target_achieved_classes,
       ROUND(SUM(CASE WHEN EngagementRate>=0.25 THEN 1 ELSE 0 END)/COUNT(*)*100,2) AS target_achievement_rate
FROM classes
GROUP BY CASE WHEN IsWeekend='True' THEN 'Weekend' ELSE 'Weekday' END;

/* 10 - TEACHER VS SUBJECT BENCHMARK */
SELECT t.TeacherID,t.Teacher,s.Subject,COUNT(c.ClassID) AS total_classes,
       ROUND(SUM(c.StudentsCompleted)/SUM(c.StudentsJoined)*100,2) AS teacher_engagement_rate,
       ROUND((SELECT SUM(c2.StudentsCompleted)/SUM(c2.StudentsJoined)*100 FROM classes c2 WHERE c2.SubjectID=c.SubjectID),2) AS subject_engagement_rate,
       ROUND((SUM(c.StudentsCompleted)/SUM(c.StudentsJoined)*100)-
             (SELECT SUM(c2.StudentsCompleted)/SUM(c2.StudentsJoined)*100 FROM classes c2 WHERE c2.SubjectID=c.SubjectID),2) AS teacher_vs_subject_gap
FROM classes c JOIN teachers t ON c.TeacherID=t.TeacherID JOIN subjects s ON c.SubjectID=s.SubjectID
GROUP BY t.TeacherID,t.Teacher,s.Subject,c.SubjectID HAVING COUNT(*)>=5
ORDER BY teacher_vs_subject_gap DESC;

SELECT t.TeacherID,t.Teacher,s.Subject,COUNT(c.ClassID) AS total_classes,
       ROUND(SUM(c.StudentsCompleted)/SUM(c.StudentsJoined)*100,2) AS teacher_engagement_rate,
       ROUND((SELECT SUM(c2.StudentsCompleted)/SUM(c2.StudentsJoined)*100 FROM classes c2 WHERE c2.SubjectID=c.SubjectID),2) AS subject_engagement_rate,
       ROUND((SUM(c.StudentsCompleted)/SUM(c.StudentsJoined)*100)-
             (SELECT SUM(c2.StudentsCompleted)/SUM(c2.StudentsJoined)*100 FROM classes c2 WHERE c2.SubjectID=c.SubjectID),2) AS teacher_vs_subject_gap
FROM classes c JOIN teachers t ON c.TeacherID=t.TeacherID JOIN subjects s ON c.SubjectID=s.SubjectID
GROUP BY t.TeacherID,t.Teacher,s.Subject,c.SubjectID HAVING COUNT(*)>=5 AND teacher_vs_subject_gap<0
ORDER BY teacher_vs_subject_gap ASC;

/* 11 - VALIDATION */
SELECT 'subjects' AS table_name,COUNT(*) AS row_count FROM subjects
UNION ALL SELECT 'topics',COUNT(*) FROM topics
UNION ALL SELECT 'teachers',COUNT(*) FROM teachers
UNION ALL SELECT 'promotionalstrategies',COUNT(*) FROM promotionalstrategies
UNION ALL SELECT 'classes',COUNT(*) FROM classes
UNION ALL SELECT 'classoperations',COUNT(*) FROM classoperations
UNION ALL SELECT 'engagementmilestones',COUNT(*) FROM engagementmilestones
UNION ALL SELECT 'classratings',COUNT(*) FROM classratings
UNION ALL SELECT 'classreviews',COUNT(*) FROM classreviews;

SELECT ClassID,COUNT(*) AS duplicate_count FROM classes GROUP BY ClassID HAVING COUNT(*)>1;

SELECT ClassID,EngagementRate,ROUND(StudentsCompleted/StudentsJoined,4) AS calculated_engagement_rate
FROM classes WHERE ABS(EngagementRate-(StudentsCompleted/StudentsJoined))>0.0001;

SELECT ClassID,EngagementRate,TargetStatus FROM classes
WHERE (EngagementRate>=0.25 AND TargetStatus<>'Target Achieved')
   OR (EngagementRate<0.25 AND TargetStatus<>'Below Target');

/* END */
