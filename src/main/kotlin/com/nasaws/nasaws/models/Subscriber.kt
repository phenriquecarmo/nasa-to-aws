package com.nasaws.nasaws.models

import jakarta.persistence.*
import java.time.LocalDateTime

@Entity
@Table(name = "subscribers")
data class Subscriber(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long = 0,

    @Column(name = "email", nullable = false)
    var email: String,

    @Column(name = "created_at", nullable = false)
    var createdAt: LocalDateTime? = LocalDateTime.now(),

    @Column(name = "unsubscribed_at", nullable = true)
    var unsubscribedAt: LocalDateTime? = LocalDateTime.now(),

    @Column(name = "is_active")
    var isActive: Boolean? = true
)