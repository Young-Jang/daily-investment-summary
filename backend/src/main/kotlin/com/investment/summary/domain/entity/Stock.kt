package com.investment.summary.domain.entity

import jakarta.persistence.*
import java.time.LocalDateTime

@Entity
@Table(name = "stocks")
class Stock(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long = 0,

    @Column(nullable = false, unique = true, length = 20)
    val ticker: String,

    @Column(nullable = false, length = 100)
    val name: String,

    @Column(length = 50)
    val market: String? = null,

    @Column(nullable = false)
    val isActive: Boolean = true,

    @Column(nullable = false, updatable = false)
    val createdAt: LocalDateTime = LocalDateTime.now(),

    @Column(nullable = false)
    var updatedAt: LocalDateTime = LocalDateTime.now()
)
