<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<c:set var="root" value="${pageContext.request.contextPath }"/>
<c:set var="userVo" value="${sessionScope.userVo}"/> <%-- 세션에서 userVo 가져오기 --%>
<%--<c:set var="auth" value="${SPRING_SECURITY_CONTEXT.authentication.authorities }" />--%>
<%--이제 필요없는 코드 --%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>All's</title>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script type="text/javascript"
            src="//dapi.kakao.com/v2/maps/sdk.js?appkey=${kakaoMapApiKey}&libraries=clusterer,services"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.min.js"></script>
    <!--차트-->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/chartjs-adapter-date-fns"></script>
    <!--부트, CSS-->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link rel="stylesheet" href="${root}/resources/css/common.css">
    <!--롤링배너-->
    <link rel="stylesheet" href="https://unpkg.com/swiper/swiper-bundle.min.css">
    <link rel="stylesheet" href="${root}/resources/css/slider.css">

    <script type="text/javascript" src="${root}/resources/js/common.js" charset="UTF-8" defer></script>
    <script src="${root}/resources/js/fullcalendar/core/index.global.js"></script>
    <script src="${root}/resources/js/fullcalendar/daygrid/index.global.js"></script>
    <script src="${root}/resources/js/fullcalendar/list/index.global.js"></script>
    <style>
        .cafe-info-window {
            background-color: white;
            border: 1px solid #ccc;
            border-radius: 5px;
            padding: 10px;
            width: 200px;
        }

        .map-search-container {
            position: absolute;
            top: 10px;
            left: 10px;
            z-index: 2; /* 지도 위에 표시되도록 설정 */
        }

        .map-search-container input[type="text"] {
            padding: 8px;
            border: 1px solid #ccc;
            border-radius: 4px;
            z-index: 2;
        }

        .map-search-container button {
            padding: 8px 12px;
            background-color: #fff;
            border: 1px solid #ccc;
            border-radius: 4px;
            cursor: pointer;
            z-index: 2;
        }

        #studyListContainer {
            margin-top: 10px;
        }

        #studyListhHi {
            list-style: none;
            padding: 0;
        }

        #studyListHi li {
            margin-bottom: 5px;
        }

    </style>
    <script>


        $(document).ready(function () {
            <c:if test="${not empty sessionScope.error}">
            $("#messageContent-main").text("${sessionScope.error}");
            $('#modal-container-main').toggleClass('opaque'); //모달 활성화
            $('#modal-container-main').toggleClass('unstaged');
            $('#modal-close').focus();
            </c:if>

        });

        function MainModalOpen() {
            let mainModalContainer = document.getElementById('modal-container-main');
            mainModalContainer.classList.toggle('opaque'); // 모달 활성화
            mainModalContainer.classList.toggle('unstaged');
            document.getElementById('modal-close').focus();
        }

        function MainModalClose() {
            let mainModalContainerClose = document.getElementById('modal-container-main');
            mainModalContainerClose.classList.toggle('opaque'); // 모달 활성화
            mainModalContainerClose.classList.toggle('unstaged');
            document.getElementById('modal-close').focus();
        }
    </script>
    <script>
        $(document).ajaxSend(function (e, xhr, options) {
            xhr.setRequestHeader('X-CSRF-TOKEN', $('meta[name="_csrf"]').attr('content'));
        });

        document.addEventListener('DOMContentLoaded', function () {
            // 캘린더 이벤트 데이터 가져오기
            let eventsData = [];
            $.ajax({
                url: "${root}/calendar/events",
                type: "GET",
                headers: {
                    "${_csrf.headerName}": "${_csrf.token}"
                },
                success: function (response) {
                    eventsData = response.map(event => ({
                        id: event.scheduleIdx,
                        title: event.title,
                        start: event.start,
                        end: event.end,
                        allDay: event.allDay === 1,
                        color: event.backgroundColor,
                    }));

                    // 캘린더 렌더링 함수
                    function renderCalendars() {
                        const monthCalendarEl = document.getElementById('monthCalendar');
                        new FullCalendar.Calendar(monthCalendarEl, {
                            initialView: 'dayGridMonth',
                            customButtons: { // 버튼 추가
                                calendarLink: {
                                    text: '캘린더 바로가기',
                                    click: function () {
                                        location.href = "${root}/calendar"; // 페이지 이동
                                    }
                                }
                            },
                            headerToolbar: {
                                left: 'title',
                                center: '',
                                right: 'calendarLink' // 버튼 위치 지정
                            },
                            events: eventsData,
                            editable: false,
                            selectable: false,
                            eventClick: false,
                            locale: 'ko',
                            height: 'auto' // 높이를 자동으로 조절
                        }).render();

                        //일간 캘린더
                        const dayCalendarEl = document.getElementById('dayCalendar');
                        new FullCalendar.Calendar(dayCalendarEl, {
                            initialView: 'listDay',
                            headerToolbar: {left: '', center: 'title', right: ''},
                            events: eventsData,
                            editable: false,
                            selectable: false,
                            eventClick: false,
                            locale: 'ko',
                            height: 'auto' // 높이를 자동으로 조절
                        }).render();
                    }

                    // 초기 렌더링 및 이벤트 리스너 등록
                    renderCalendars();

                },
                error: function (jqXHR, textStatus, errorThrown) {
                    console.error('Error fetching events:', errorThrown);
                    alert('이벤트를 불러오는 중 오류가 발생했습니다.');
                }
            });
        });
    </script>
</head>

<body>
<!-- 중앙 컨테이너 -->
<jsp:include page="include/header.jsp"/>
<%-- 로그인 성공 모달 --%>
<div id="modal-container-main" class="modal unstaged" style="z-index: 100">
    <div class="modal-overlay">
    </div>
    <div class="modal-contents">
        <div class="modal-text flex-between">
            <h4>알림</h4>
            <button id="modal-close" class="modal-close" aria-label="닫기" onclick="MainModalClose()"><i
                    class="bi bi-x-lg"></i></button>
        </div>
        <div id="messageContent-main" class="modal-center">
            <%-- 메시지 내용이 여기에 표시됩니다. --%>
        </div>
        <div class="modal-bottom">
            <button type="button" class="modal-close" data-dismiss="modal" onclick="MainModalClose()">닫기</button>
        </div>
    </div>
</div>
<div id="container">
    <section class="mainContainer">
        <!-- 메뉴 영역 -->
        <nav>
            <jsp:include page="include/navbar.jsp"/>
        </nav>
        <!-- 본문 영역 -->
        <main>
            <!--모바일 메뉴 영역-->
            <div class="m-menu-area" style="display: none;">
                <jsp:include page="include/navbar.jsp"/>
            </div>
            <!--각 페이지의 콘텐츠-->
            <div id="content">
                <h1>대시보드</h1>
                <%-- 로그인하지 않은 사용자에게만 표시 --%>
                <sec:authorize access="isAnonymous()">
                    <div class="non-login-section">
                        <div class="service-info bg-green">
                            <div class="service-info-left">
                                <h3>서비스</h3>
                                <h2>혼자 공부하기 힘든 분들을 위한 스터디 서비스!</h2>
                                <p>다양한 학습 관리, 정보 제공, 취업 지원 기능을 통합하여 학습자가 효율적으로 자기계발과 목표 달성에 집중할 수 있도록 돕는 포괄적인 스터디 플랫폼을
                                    제공합니다</p>
                            </div>
                            <div class="service-info-right flex-colum">
                                <button class="secondary-default">공부노트<i class="bi bi-arrow-right"></i></button>
                                <button class="secondary-default">캘린더<i class="bi bi-arrow-right"></i></button>
                                <button class="secondary-default">스터디 그룹<i class="bi bi-arrow-right"></i></button>
                                <button class="secondary-default">공부 자료<i class="bi bi-arrow-right"></i></button>
                                <button class="secondary-default">이력서 작성<i class="bi bi-arrow-right"></i></button>
                            </div>
                        </div>
                        <div class="iogin-info flex-colum bg-green">
                            <h3>지금부터<br> 함께 공부해봐요!</h3>
                            <button class="primary-default" onclick="location.href='${root}/Users/UsersLoginForm'">로그인
                            </button>
                            <button class="secondary-default" onclick="location.href='${root}/Users/Join'">회원가입</button>
                        </div>
                    </div>
                    <h2>주변에서 함께할 동료들을 찾으세요!</h2><br>
                    <sec:authorize access="isAnonymous()">
                        <div id="map-anonymous"
                             style="width:100%; height:250px;border-radius: 5px;"></div> <%-- 로그인 전 지도 컨테이너 --%>
                    </sec:authorize>
                    <script>
                        $(document).ready(function () {

                            initializeMapAnonymous();
                            getLocationAndDisplayOnAnonymousMap();

                            $.ajax({
                                url: '/studies/listOnAnonymousMap',
                                type: 'GET', // GET 방식으로 변경
                                dataType: 'json',
                                success: function (studyData1) {
                                    displayStudyMarkersAnonymous(mapAnonymous, studyData1);
                                },
                                error: function (xhr, status, error) {
                                    console.error('스터디 정보를 가져오는 중 오류가 발생했습니다.', error);
                                    alert("스터디 정보를 가져오는데 실패했습니다.");
                                }
                            });
                            <%--                            <c:if test="${not empty studyList}">--%>
                            <%--                            displayStudyMarkersAnonymous(mapAnonymous, ${studyList}); // 스터디 마커 표시--%>
                            <%--                            </c:if>--%>

                            // 10초마다 위치 정보 업데이트
                            setInterval(getLocationAndDisplayOnAnonymousMap, 1000);

                            // 토글 버튼 생성 및 추가
                            var toggleButtonAnonymous = document.createElement('button');
                            toggleButtonAnonymous.id = 'toggleButtonAnonymous';
                            toggleButtonAnonymous.textContent = '지도 확대';
                            toggleButtonAnonymous.className = 'toggle-button';
                            document.getElementById('map-anonymous').appendChild(toggleButtonAnonymous);

                            // 토글 버튼 클릭 이벤트 리스너 등록
                            toggleButtonAnonymous.addEventListener('click', toggleAnonymousMapView);


                        });
                    </script>
                    <br>
                    <br>
                </sec:authorize>
                <%-- 로그인한 사용자에게만 표시 --%>
                <sec:authorize access="isAuthenticated()">
                    <div class="loginMain">
                        <div class="loginUserInfoLeft">
                            <div class="scheduler-area">
                                <div class="scheduler">
                                    <div id="monthCalendar"></div>
                                </div>
                                <div class="todo">
                                    <div id="dayCalendar"></div>
                                </div>
                            </div>
                        </div>
                        <div class="loginUserInfoRight">
                                <%--공부시간 차트--%>
                            <canvas id="studyTimeChart"></canvas>
                            <div class="userStudyGroup">
                                <div class="userStudyGroupTitle">
                                    <h3>공부하는 42조</h3>
                                    <div class="slide-button-group">
                                        <button class="slide-button" title="이전">
                                            <i class="bi bi-caret-left-fill"></i>
                                            <span class="hide">이전</span>
                                        </button>
                                        <button class="slide-button" title="다음">
                                            <i class="bi bi-caret-right-fill"></i>
                                            <span class="hide">다음</span>
                                        </button>
                                    </div>
                                </div>
                                <div class="userStudyGroupMember">
                                    <div class="memberItem">
                                        <div class="studyMemberProfile">
                                            <a class="profile" href="#">
                                                <div class="study-profile-img">
                                                    <img src="${root}/resources/images/manggom.png" alt="내 프로필">
                                                </div>

                                            </a>
                                        </div>
                                        <a href="#" class="memberName">Yejoon</a>
                                        <div class="study-status"><span class="status">접속중</span></div>
                                    </div>

                                    <div class="memberItem">
                                        <div class="studyMemberProfile">
                                            <a class="profile" href="#">
                                                <div class="study-profile-img">
                                                    <img src="${root}/resources/images/manggom.png" alt="내 프로필">
                                                </div>

                                            </a>
                                        </div>
                                        <a href="#" class="memberName">Yejoon</a>
                                        <div class="study-status"><span class="status">접속중</span></div>
                                    </div>


                                </div>
                            </div>
                        </div>
                    </div>
                </sec:authorize>
                <sec:authorize access="isAuthenticated()">
                    <div id="map-authenticated"
                         style="width:100%; height:250px;border-radius: 5px; margin: 1em 0"> <%-- 로그인 후 지도 컨테이너 --%>
                        <div class="map-search-container">
                            <button id="cafeSearchButton" class="toggle-button-map">주변 카페 보기☕</button>
                        </div>
                    </div>
                    <div id="studyListContainer" style="display: block;"> <%-- display: block 추가 --%>
                        <h3>주변 스터디 목록 (3순위까지)</h3>
                        <ul id="studyListHi"></ul>
                    </div> <%-- 스터디 목록 컨테이너 추가 --%>
                </sec:authorize>

                <!--슬라이드 배너-->
                <div class="swiper-container">
                    <div class="swiper-wrapper">
                        <!-- 동적으로 생성된 슬라이드 아이템들 -->
                        <c:forEach var="study" items="${study_18}">
                            <div class="swiper-slide">
                                <div class="study-banner-item bgwhite" tabindex="0"
                                     onclick="location.href='${root}/studyRecruit/recruitReadForm?studyIdx=${study.studyIdx}'">
                                    <div class="banner-bottom flex-between">
                                        <p class="study-tag">
                                            <span class="recruit-status ${study.status eq 'CLOSED' ? 'closed' : 'open'}">${study.status}</span>
                                            <span class="department">${study.category}</span>
                                        </p>
                                        <button class="banner-like" aria-label="좋아요">
                                            <i class="bi bi-heart"></i>
                                        </button>
                                    </div>
                                    <div class="banner-item-top">
                                        <div class="banner-img">
                                            <img src="${root}/resources/images/${study.image}" alt="스터디 그룹 로고"/>
                                        </div>
                                        <div class="banner-title">
                                            <p class="banner-main-title">${study.studyTitle}</p>
                                            <p class="banner-id">${study.leaderName}</p>
                                        </div>
                                    </div>
                                    <p class="banner-content">${study.description}</p>
                                    <p class="study-tag">
                                        <span class="study-tagItem">#${study.gender}</span>
                                        <span class="study-tagItem">#${study.age}</span>
                                        <span class="study-tagItem">#${study.studyOnline ? "온라인" : "오프라인"}</span>
                                    </p>
                                </div>
                            </div>
                        </c:forEach>
                    </div>


                    <!-- 다른 슬라이드들 추가 가능 -->

                    <!-- 페이지 네이션 -->
                    <div class="swiper-pagination"></div>

                    <!-- 이전, 다음 버튼 -->
                    <div class="swiper-button-prev"></div>
                    <button class="control-button"><i class="bi bi-pause"></i></button>
                    <div class="swiper-button-next"></div>
                </div>
                <%--슬라이더 끝--%>


            </div>
            <%--콘텐츠 끝--%>
        </main>
    </section>

</div>
<script>
    //주간 그래프
    fetch('/include/study-time?userIdx=${userVo.userIdx}') // Adjust the userIdx as needed
        .then(response => response.json())
        .then(data => {
            const labels = ['일', '월', '화', '수', '목', '금', '토'];
            const currentWeekData = new Array(7).fill(0);
            const previousWeekData = new Array(7).fill(0);

            console.log(data)
            console.log(currentWeekData);
            console.log(previousWeekData)

            data.currentWeek.forEach(record => {
                const date = new Date(record.date.year, record.date.monthValue - 1, record.date.dayOfMonth);
                const dayIndex = date.getDay(); // 0 (일요일) - 6 (토요일)
                currentWeekData[dayIndex] = record.study_time;
            });

            data.previousWeek.forEach(record => {
                const date = new Date(record.date.year, record.date.monthValue - 1, record.date.dayOfMonth);
                const dayIndex = date.getDay(); // 0 (일요일) - 6 (토요일)
                previousWeekData[dayIndex] = record.study_time;
            });

            const ctx = document.getElementById('studyTimeChart').getContext('2d');
            new Chart(ctx, {
                type: 'line',
                data: {
                    labels: labels,
                    datasets: [
                        {
                            label: '저번주',
                            data: previousWeekData,
                            borderColor: 'rgba(75, 192, 192, 1)',
                            borderWidth: 4,
                            backgroundColor: 'rgba(154, 208, 245, 1)',
                            fill: false
                        },
                        {
                            label: '이번주',
                            data: currentWeekData,
                            borderColor: 'rgb(255,99,132)',
                            borderWidth: 4,
                            backgroundColor: 'rgba(255, 177, 193, 1)',
                            fill: false
                        }
                    ]
                },
                options: {
                    maintainAspectRatio: false, // 가로 세로 비율을 유지하지 않음
                    aspectRatio: 3, // 가로 세로 비율 (width / height)
                    scales: {
                        x: {
                            grid: {
                                display: false // 가로 줄 숨기기
                            },
                            type: 'category', // 범주형 x축
                            labels: labels // 레이블을 요일로 설정
                        },
                        y: {
                            grid: {
                                display: false // 세로 줄 숨기기
                            },
                            beginAtZero: true, // y축이 0부터 시작하도록 설정
                            display: false // y축 범위 나타내기
                        }
                    },
                    plugins: {
                        legend: {
                            labels: {
                                font: {
                                    size: 8 // 폰트 크기 설정
                                }
                            },
                            title: {
                                display: true // 범례 제목 duqn
                            },
                            maxWidth: 70, // 범례의 최대 너비 설정
                            padding: 5 // 범례 주변 패딩 설정
                        },
                        tooltip: {
                            callbacks: {
                                label: function(context) {
                                    const label = context.dataset.label || '';
                                    const value = context.raw;
                                    return label + ': ' + formatTime(value);
                                }
                            }
                        }
                    }
                }
            });
        })
        .catch(error => {
            console.error('Fetch error:', error);
        });

</script>
<%--<script>--%>
<%--    $(document).ready(function () {--%>
<%--        if (${param.error}) {--%>
<%--            $("#messageContent").text("${error}");--%>
<%--            $('#modal-container').toggleClass('opaque'); //모달 활성화--%>
<%--            $('#modal-container').toggleClass('unstaged');--%>
<%--            $('#modal-close').focus();--%>
<%--        }--%>

<%--        if ("${msg}" !== "") {--%>
<%--            $("#messageContent").text("${msg}");--%>
<%--            $('#modal-container').toggleClass('opaque'); //모달 활성화--%>
<%--            $('#modal-container').toggleClass('unstaged');--%>
<%--            $('#modal-close').focus();--%>
<%--        }--%>
<%--    });--%>
<%--</script>--%>
<script>
    var mapAnonymous;
    var mapAuthenticated;
    var marker;
    var markerAnonymous;
    var zoomLevel = 6;
    var isWideView = false;

    // 인포윈도우 객체 배열 (로그인 안 한 상태)
    var infowindowAnonymouses = [];

    // 인포윈도우 객체 배열 (로그인 상태)
    var infowindows = [];

    // 마커 클러스터러 생성
    var clustererAnonymous = new kakao.maps.MarkerClusterer({
        map: mapAnonymous, // 클러스터러를 적용할 지도 객체
        averageCenter: true, // 클러스터에 포함된 마커들의 평균 위치를 클러스터 마커 위치로 설정
        minLevel: 8 // 클러스터 할 최소 지도 레벨
    });

    var clusterer = new kakao.maps.MarkerClusterer({
        map: mapAuthenticated, // 클러스터러를 적용할 지도 객체
        averageCenter: true, // 클러스터에 포함된 마커들의 평균 위치를 클러스터 마커 위치로 설정
        minLevel: 8 // 클러스터 할 최소 지도 레벨
    });

    // 마커 이미지 생성
    var imageSrc = 'https://t1.daumcdn.net/localimg/localimages/07/mapapidoc/markerStar.png'; // 마커 이미지 URL
    var imageSize = new kakao.maps.Size(24, 35);
    var markerImage = new kakao.maps.MarkerImage(imageSrc, imageSize);


    // 지도 생성 및 초기화 (로그인 전)
    function initializeMapAnonymous() {
        var mapContainer = document.getElementById('map-anonymous');
        var mapOption = {
            center: new kakao.maps.LatLng(37.49564, 127.0275), // 초기 지도 중심좌표 (비트캠프)
            level: 6 // 지도의 확대 레벨
        };
        mapAnonymous = new kakao.maps.Map(mapContainer, mapOption);

        // 지도 확대, 축소 컨트롤 생성 및 추가
        var zoomControlAnonymous = new kakao.maps.ZoomControl();
        mapAnonymous.addControl(zoomControlAnonymous, kakao.maps.ControlPosition.RIGHT);

        // 마커를 생성합니다
        markerAnonymous = new kakao.maps.Marker({
            position: mapAnonymous.getCenter()
        });
        markerAnonymous.setMap(mapAnonymous);

        // 마커 클러스터러 생성 (지도 초기화 후)
        clustererAnonymous = new kakao.maps.MarkerClusterer({
            map: mapAnonymous,
            averageCenter: true,
            minLevel: 8
        });
    }

    // 지도 생성 및 초기화 (로그인 후)
    function initializeMapAuthenticated() {
        var mapContainer = document.getElementById('map-authenticated');
        var mapOption = {
            center: new kakao.maps.LatLng(37.49564, 127.0275), // 초기 지도 중심좌표 (비트캠프)
            level: zoomLevel
        };
        mapAuthenticated = new kakao.maps.Map(mapContainer, mapOption);

        // 지도 확대, 축소 컨트롤 생성 및 추가
        var zoomControl = new kakao.maps.ZoomControl();
        mapAuthenticated.addControl(zoomControl, kakao.maps.ControlPosition.RIGHT);

        // 마커를 생성합니다
        marker = new kakao.maps.Marker({
            position: mapAuthenticated.getCenter()
        });
        marker.setMap(mapAuthenticated);

        // 마커 클러스터러 생성 (지도 초기화 후)
        clusterer = new kakao.maps.MarkerClusterer({
            map: mapAuthenticated,
            averageCenter: true,
            minLevel: 8
        });

    }


    function toggleAnonymousMapView() {
        var mapContainer = document.getElementById('map-anonymous');
        var toggleButton = document.getElementById('toggleButtonAnonymous');

        if (isWideView) {
            // 현재 확대 상태이면 축소
            getLocationAndDisplayOnAnonymousMap();
            mapContainer.style.width = '100%';
            mapContainer.style.height = '250px';
            toggleButton.textContent = '창 확대';
        } else {
            // 현재 축소 상태이면 확대
            getLocationAndDisplayOnAnonymousMap();
            mapContainer.style.width = '100%';
            mapContainer.style.height = '800px';
            toggleButton.textContent = '창 축소';
        }

        // 지도 크기 변경 후 relayout 호출 (setTimeout을 사용하여 렌더링 후 호출)
        setTimeout(function() {
            mapAnonymous.relayout();
            // 딜레이 후 화면 중심을 지도 중심으로 이동
            setTimeout(function () {
                window.scrollTo({
                    top: mapContainer.offsetTop - (window.innerHeight - mapContainer.offsetHeight) / 2,
                    left: mapContainer.offsetLeft - (window.innerWidth - mapContainer.offsetWidth) / 2,
                    behavior: 'smooth'
                });
            }, 500); // 0.5초 후에 실행 (딜레이 시간 조절 가능)
        }, 500); // 0.5초 후에 relayout 호출 (transition 시간과 동일하게 설정)

        isWideView = !isWideView; // 확대 상태 반전
    }


    // 사용자 위치 가져오기 및 지도에 표시
    function getLocationAndDisplayOnMap() {
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(function (position) {
                var lat = position.coords.latitude;
                var lon = position.coords.longitude;

                var locPosition = new kakao.maps.LatLng(lat, lon);
                marker.setPosition(locPosition);

                mapAuthenticated.setCenter(locPosition);
                // 로그인 여부 확인 후 위치 정보 전송
                <sec:authorize access="isAuthenticated()">
                sendLocationToServer(lat, lon);
                </sec:authorize>
            }, function(error) {
                console.error('위치 정보를 가져오는 중 오류가 발생했습니다.', error);
            });
        } else {
            // Geolocation을 사용할 수 없을 때 처리 로직
        }
    }

    // 사용자 위치 가져오기 및 지도에 표시
    function getLocationAndDisplayOnAnonymousMap() {
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(function (position) {
                var lat = position.coords.latitude;
                var lon = position.coords.longitude;

                var locPosition = new kakao.maps.LatLng(lat, lon);
                markerAnonymous.setPosition(locPosition);

                mapAnonymous.setCenter(locPosition);

            }, function (error) {
                console.error('위치 정보를 가져오는 중 오류가 발생했습니다.', error);
            });
        } else {
            // Geolocation을 사용할 수 없을 때 처리 로직
        }
    }

    // 위치 정보 서버 전송 함수
    function sendLocationToServer(latitude, longitude) {
        // 로그인 여부 확인
        $.ajax({
            url: '/Users/updateLocation',  // 위치 정보 업데이트 요청을 처리할 컨트롤러 URL
            type: 'POST',
            data: {latitude: latitude, longitude: longitude},
            beforeSend: function (xhr) {
                xhr.setRequestHeader('X-CSRF-TOKEN', $('meta[name="_csrf"]').attr('content'));
            },
            success: function (response) {
                console.log('위치 정보 업데이트 성공:', response);
            },
            error: function (xhr, status, error) {
                console.error('위치 정보 업데이트 실패:', error);
            }
        });

    }


    // 스터디 마커 표시 함수
    function displayStudyMarkers(map, studyData) {
        var markers = []; // 마커들을 담을 배열
        // 스터디 목록 초기화
        const studyList = document.getElementById('studyList');
        if (studyList) { // studyList가 null인지 확인
            studyList.innerHTML = ''; // 기존 목록 내용 지우기
        }

        for (var i = 0; i < studyData.length; i++) {
            var study = studyData[i];
            var position = new kakao.maps.LatLng(study.latitude, study.longitude);
            var Removeable = true;

            // 마커 생성
            var marker = new kakao.maps.Marker({
                map: map,
                position: position,
                title: study.studyTitle,
                image: markerImage // 마커 이미지 설정
            });

            markers.push(marker); // 생성된 마커를 배열에 추가

            // 인포윈도우 생성 및 배열에 저장
            var infowindow = new kakao.maps.InfoWindow({
                content: '<div style="width:160px;text-align:center;padding:10px 0;border-radius: 20px;">' +
                    '<h4>' + study.studyTitle + '</h4>' +
                    '<p>' + study.category + '</p>' +
                    '<p>' + "💚 likes : " + study.likesCount + '</p>' +
                    '<p>' + "모집 :" + study.currentParticipants + '/' + study.capacity + '</p>' + '<br>' +
                    '<a href="${root}/studyRecruit/recruitReadForm?studyIdx=' + study.studyIdx + '" class="btn btn-primary" style="background-color: #dbe0d2;color: #000000;padding: 5px;border-radius: 5px;font-size: 10px;">더보기</a>' + // 상세보기 버튼 추가
                    '</div>',
                removable: Removeable,
                yAnchor: -45 // 인포윈도우를 마커 위쪽으로 이동
            });
            infowindows.push(infowindow);

            // 마커 클릭 이벤트 리스너 등록 (클로저 활용)
            (function (marker, index) { // index 매개변수 추가
                kakao.maps.event.addListener(marker, 'click', function () {
                    // 다른 인포윈도우 닫기
                    infowindows.forEach(function (iw) {
                        iw.close();
                    });
                    // 클릭된 마커에 해당하는 인포윈도우 열기
                    infowindows[index].open(map, marker);
                });
            })(marker, i); // marker와 index를 클로저에 전달
        }
        clusterer.addMarkers(markers); // 클러스터러에 마커 추가
    }


    // 스터디 마커 표시 함수
    function displayStudyMarkersAnonymous(map1, studyData1) {
        var markers = []; // 마커들을 담을 배열

        for (var j = 0; j < studyData1.length; j++) {
            var studys = studyData1[j];
            var position = new kakao.maps.LatLng(studys.latitude, studys.longitude);
            var Removeable = true;

            var markerAnonymous = new kakao.maps.Marker({
                map: mapAnonymous,
                position: position,
                title: studys.study_title,
                image: markerImage // 마커 이미지 설정
            });

            markers.push(markerAnonymous); // 생성된 마커를 배열에 추가

            // 인포윈도우 생성 및 내용 설정
            var infowindow = new kakao.maps.InfoWindow({
                position: position,
                content: '<div style="width:160px;text-align:center;padding:10px 0;border-radius: 20px;">' +
                    '<h4>' + studys.studyTitle + '</h4>' +
                    '<p>' + studys.category + '</p>' +
                    '<p>' + "💚 likes : " + studys.likesCount + '</p>' +
                    '<p>' + "모집 :" + studys.currentParticipants + '/' + studys.capacity + '</p>' + '<br>' +
                    '<a href="${root}/studyRecruit/recruitReadForm?studyIdx=' + studys.studyIdx + '" class="btn btn-primary" style="background-color: #dbe0d2;color: #000000;padding: 5px;border-radius: 5px;font-size: 10px;">더보기</a>' + // 상세보기 버튼 추가추가
                    '</div>',
                removable: Removeable,
                yAnchor: -45
            });
            infowindowAnonymouses.push(infowindow);

            // 마커 클릭 이벤트 리스너 등록 (클로저 활용)
            (function (marker, infowindow) {
                kakao.maps.event.addListener(marker, 'click', function () {
                    // 다른 인포윈도우 닫기
                    infowindowAnonymouses.forEach(function (iw) {
                        iw.close();
                    });
                    infowindow.open(mapAnonymous, marker);
                });
            })(markerAnonymous, infowindow);
        }
        clustererAnonymous.addMarkers(markers); // 클러스터러에 마커 추가
    }


    // 지도 확대/축소 토글 함수
    function toggleMapView() {
        var mapContainer = document.getElementById('map-authenticated');
        var toggleButton = document.getElementById('toggleButton');

        if (isWideView) {
            // 현재 확대 상태이면 축소
            getLocationAndDisplayOnMap();
            mapContainer.style.width = '100%';
            mapContainer.style.height = '250px';
            toggleButton.textContent = '창 확대';

        } else {
            // 현재 축소 상태이면 확대
            getLocationAndDisplayOnMap();
            mapContainer.style.width = '100%';
            mapContainer.style.height = '800px';
            toggleButton.textContent = '창 축소';
        }
        // 지도 크기 변경 후 relayout 호출 (setTimeout을 사용하여 렌더링 후 호출)
        setTimeout(function () {
            mapAuthenticated.relayout();
            // 딜레이 후 화면 중심을 지도 중심으로 이동
            setTimeout(function () {
                window.scrollTo({
                    top: mapContainer.offsetTop - (window.innerHeight - mapContainer.offsetHeight) / 2,
                    left: mapContainer.offsetLeft - (window.innerWidth - mapContainer.offsetWidth) / 2,
                    behavior: 'smooth'
                });
            }, 500); // 0.5초 후에 실행 (딜레이 시간 조절 가능)
        }, 500); // 0.5초 후에 relayout 호출 (transition 시간과 동일하게 설정)

        isWideView = !isWideView; // 확대 상태 반전
    }


    // 페이지 로드 시 지도 초기화 및 위치 정보 가져오기
    $(document).ready(function () {
        // 스터디 목록 조회 및 표시 함수
        function getStudyListAndDisplay() {
            if (navigator.geolocation) {
                navigator.geolocation.getCurrentPosition(function (position) {
                    var lat = position.coords.latitude;
                    var lon = position.coords.longitude;

                    $.ajax({
                        url: '/studies/nearestStudies',
                        type: 'GET',
                        dataType: 'json',
                        data: {latitude: lat, longitude: lon},
                        success: function (studyData) {
                            // 스터디 목록 초기화
                            const studyListHi = document.getElementById('studyListHi');
                            if (studyListHi) {
                                studyListHi.innerHTML = ''; // 기존 목록 내용 지우기
                            } else {
                                console.error('studyListHi 요소를 찾을 수 없습니다.');
                                return; // 함수 종료
                            }

                            // 스터디 데이터 거리순으로 정렬
                            studyData.sort((a, b) => a.distance - b.distance);

                            // 가까운 스터디 3개만 목록에 추가
                            for (let i = 0; i < Math.min(studyData.length, 3); i++) {
                                const study = studyData[i];
                                const listItem = document.createElement('li');
                                const link = document.createElement('a');
                                link.href = '/studyRecruit/recruitReadForm?studyIdx=' + study.studyIdx;
                                link.textContent = study.studyTitle;
                                listItem.appendChild(link);
                                studyListHi.appendChild(listItem);
                            }

                            // 스터디 마커 표시 (전체 스터디)
                            displayStudyMarkers(mapAuthenticated, studyData);
                        },
                        error: function (xhr, status, error) {
                            console.error('스터디 정보를 가져오는 중 오류가 발생했습니다.', error);
                        }
                    });
                }, function (error) {
                    console.error('위치 정보를 가져오는 중 오류가 발생했습니다.', error);
                });
            } else {
                // Geolocation을 사용할 수 없을 때 처리 로직
            }
        }

        <sec:authorize access="isAuthenticated()">


        initializeMapAuthenticated();
        getLocationAndDisplayOnMap();
// 초기 스터디 목록 조회 및 표시
        getStudyListAndDisplay();
        $.ajax({
            url: '/studies/listOnMap',
            type: 'GET',
            dataType: 'json',
            success: function (studyData) {
                displayStudyMarkers(mapAuthenticated, studyData);
            },
            error: function (xhr, status, error) {
                console.error('스터디 정보를 가져오는 중 오류가 발생했습니다.', error);
            }
        });

        // 1초마다 위치 정보 업데이트
        setInterval(getLocationAndDisplayOnMap, 1000);


        // 토글 버튼 1 생성 및 추가 (지도 확대/축소)
        var toggleButton = document.createElement('button');
        toggleButton.id = 'toggleButton';
        toggleButton.textContent = "창 확대";
        toggleButton.className = 'toggle-button-map';
        document.getElementById('map-authenticated').appendChild(toggleButton);

        // 토글 버튼 클릭 이벤트 리스너 등록
        toggleButton.addEventListener('click', toggleMapView);


        function searchCafesNearMapCenter(map) {
            // 현재 위치 정보 가져오기
            if (navigator.geolocation) {
                navigator.geolocation.getCurrentPosition(function (position) {
                    var lat = position.coords.latitude;
                    var lon = position.coords.longitude;
                    var locPosition = new kakao.maps.LatLng(lat, lon);

                    // 카페 검색 객체 생성 및 옵션 설정 (2km 반경 제한 추가)
                    var ps = new kakao.maps.services.Places(map);
                    var options = {
                        location: locPosition,
                        radius: 2000, // 2km 반경
                        category_group_code: 'CE7',
                        sort: kakao.maps.services.SortBy.DISTANCE
                    };

                    // 카페 검색 실행
                    ps.keywordSearch('카페', function (data, status, pagination) {
                        if (status === kakao.maps.services.Status.OK) {
                            displayCafeMarkers(map, data.slice(0, 15)); // 최대 15개만 표시
                        } else {
                            console.error('카페 검색 실패:', status);
                        }
                    }, options);
                });
            } else {
                console.error("Geolocation is not available.");
            }
        }


        function displayCafeMarkers(map, cafes) {
            // 기존 마커 및 인포윈도우 제거
            clusterer.clear();
            if (infowindows) {
                infowindows.forEach(function(iw) {
                    iw.close();
                });
            }
            infowindows = []; // 인포윈도우 배열 초기화
            // 카페 마커 이미지 설정 (스프라이트 이미지 사용)
            var imageSrc = '${root}/resources/images/icons8-커피-이동합니다-64.png';
            var imageSize = new kakao.maps.Size(50, 50);
            var cafeMarkerImage = new kakao.maps.MarkerImage(imageSrc, imageSize);

            // 카페 마커 생성 및 표시
            for (let i = 0; i < cafes.length; i++) {
                const cafe = cafes[i];
                const position = new kakao.maps.LatLng(cafe.y, cafe.x);

                const marker = new kakao.maps.Marker({
                    map: map,
                    position: position,
                    title: cafe.place_name,
                    image: cafeMarkerImage
                });

                // 각 마커에 대한 인포윈도우 생성
                var infowindow = new kakao.maps.InfoWindow({
                    content: '<div style="width:160px;text-align:center;padding:10px 0;border-radius: 20px;">' +
                        '<h4>' + cafe.place_name + '</h4>' +
                        '<p>' + cafe.address_name + '</p>' +
                        '<p>' + cafe.phone + '</p>' +
                        '<a href="' + cafe.place_url + '" target="_blank" class="btn btn-primary" style="background-color: #dbe0d2;color: #000000;padding: 5px;border-radius: 5px;font-size: 10px;">상세 정보</a>' +
                        '</div>',
                    removable: true,
                    yAnchor: 1 // 인포윈도우를 마커 아래쪽으로 이동
                });

                // 마커 클릭 이벤트 리스너 등록 (클로저 활용)
                (function (marker, infowindow) {
                    kakao.maps.event.addListener(marker, 'click', function () {
                        // 모든 인포윈도우 닫기
                        infowindows.forEach(function (iw) {
                            iw.close();
                        });
                        // 클릭된 마커에 해당하는 인포윈도우 열기
                        infowindow.open(map, marker);
                    });
                })(marker, infowindow); // marker와 infowindow를 즉시 실행 함수에 전달

                // 마커와 인포윈도우를 배열에 추가
                clusterer.addMarker(marker);
                infowindows.push(infowindow);
            }
        }

// 카페 검색 버튼 클릭 이벤트 처리
        let cafeSearchButton = document.getElementById('cafeSearchButton');
        // 토글 버튼 클릭 이벤트 처리
        cafeSearchButton.addEventListener('click', function () {
            var mapContainer = document.getElementById('map-authenticated');
            if (cafeSearchButton.textContent == '주변 카페 보기☕') {
                getLocationAndDisplayOnMap(); // 현재 위치로 지도 중심 이동
                getStudyListAndDisplay(); // 스터디 목록 다시 조회 및 표시
                infowindows.forEach(function (iw) {
                    iw.close();
                });
                searchCafesNearMapCenter(mapAuthenticated);
                mapAuthenticated.setLevel(3); // 지도 확대 레벨 설정
                mapContainer.style.width = '100%';
                mapContainer.style.height = '800px';
                toggleButton.textContent = '창 축소';

                // 지도 크기 변경 후 relayout 호출 (setTimeout을 사용하여 렌더링 후 호출)
                setTimeout(function () {
                    mapAuthenticated.relayout();
                    // 딜레이 후 화면 중심을 지도 중심으로 이동
                    setTimeout(function () {
                        window.scrollTo({
                            top: mapContainer.offsetTop - (window.innerHeight - mapContainer.offsetHeight) / 2,
                            left: mapContainer.offsetLeft - (window.innerWidth - mapContainer.offsetWidth) / 2,
                            behavior: 'smooth'
                        });
                    }, 500); // 0.5초 후에 실행 (딜레이 시간 조절 가능)
                }, 500); // 0.5초 후에 relayout 호출 (transition 시간과 동일하게 설정)

                cafeSearchButton.textContent = '주변 스터디 보기📗';
            } else if (cafeSearchButton.textContent == '주변 스터디 보기📗') {
                clusterer.clear();
                infowindows.forEach(function (iw) {
                    iw.close();
                });
                getLocationAndDisplayOnMap(); // 현재 위치로 지도 중심 이동
                getStudyListAndDisplay(); // 스터디 목록 다시 조회 및 표시
                $.ajax({
                    url: '/studies/listOnMap',
                    type: 'GET',
                    dataType: 'json',
                    success: function (studyData) {
                        displayStudyMarkers(mapAuthenticated, studyData);
                    },
                    error: function (xhr, status, error) {
                        console.error('스터디 정보를 가져오는 중 오류가 발생했습니다.', error);
                    }
                });
                mapAuthenticated.setLevel(zoomLevel); // 기본 확대 레벨로 복원

                mapContainer.style.width = '100%';

                mapAuthenticated.relayout();
                cafeSearchButton.textContent = '주변 카페 보기☕';
            }
        });
        </sec:authorize>
    });
    <%session.removeAttribute("error");%> <%-- 오류 메시지 제거 --%>
</script>


<script src="https://unpkg.com/swiper/swiper-bundle.min.js"></script>
<script src="${root}/resources/js/slider.js"></script>
<jsp:include page="include/footer.jsp"/>
<jsp:include page="include/timer.jsp"/>
</body>
</html>