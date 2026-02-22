package com.investment.summary.domain.entity

import jakarta.persistence.*
import java.time.LocalDate
import java.time.LocalDateTime

@Entity
@Table(
    name = "investment_summaries",
    uniqueConstraints = [UniqueConstraint(columnNames = ["summary_date", "category"])]
)
class InvestmentSummary(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long = 0,

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    val category: Category,

    @Column(nullable = false)
    val summaryDate: LocalDate,

    @Column(nullable = false, length = 200)
    var title: String,

    @Column(nullable = false, columnDefinition = "TEXT")
    var content: String,  // Markdown 형식

    @Column(columnDefinition = "TEXT")
    var sourceUrl: String? = null,

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    var marketSentiment: MarketSentiment = MarketSentiment.NEUTRAL,

    @Column(nullable = false, updatable = false)
    val createdAt: LocalDateTime = LocalDateTime.now(),

    @Column(nullable = false)
    var updatedAt: LocalDateTime = LocalDateTime.now()
)

enum class Category(val displayName: String, val searchQuery: String) {
    STOCK("주식", "한국 주식시장 코스피 코스닥 투자 뉴스 site:news.naver.com OR site:youtube.com"),
    COIN("코인", "암호화폐 비트코인 이더리움 가상화폐 투자 뉴스 site:news.naver.com OR site:youtube.com"),
    RESOURCE("자원", "원자재 원유 WTI 금 국제 상품 투자 뉴스 site:news.naver.com OR site:youtube.com"),
    REAL_ESTATE("부동산", "한국 부동산 아파트 시세 투자 뉴스 site:news.naver.com OR site:youtube.com")
}

enum class MarketSentiment(val displayName: String) {
    POSITIVE("긍정"),
    NEUTRAL("중립"),
    NEGATIVE("부정")
}
