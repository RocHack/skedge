class Course < ActiveRecord::Base
  module Term
    Fall = 0
    Spring = 1
    Summer = 2
    Winter = 3
  end

  def self.yr_term_to_year_and_term(yr_term)
    terms = {"1" => Course::Term::Fall,
             "2" => Course::Term::Spring,
             "3" => Course::Term::Winter,
             "4" => Course::Term::Summer}
    term = terms[yr_term.to_s[-1]]

    year = yr_term.to_s[0..-2].to_i
    if term == Course::Term::Fall
      year -= 1
    end

    return year, term
  end

  FormatTerm = ["Fall", "Spring", "Summer", "Winter"]

  include QueryingConcern
  class QueryingException < Exception; end

  has_many :sections, dependent: :destroy
  has_many :instructors
  belongs_to :department

  validates :number, uniqueness: { scope: [:department, :yr_term, :title] }
  validates :title, :yr_term, :number, :term, :year, presence: true

  def self.has_subsections(name, t)
    has_many name, -> {
                     where section_type: t
                   }, source: :sections, :class_name => 'Section'
  end

  has_subsections(:course_sections, Section::Type::Course)
  has_subsections(:labs, Section::Type::Lab)
  has_subsections(:recitations, Section::Type::Recitation)
  has_subsections(:lab_lectures, Section::Type::LabLecture)
  has_subsections(:workshops, Section::Type::Workshop)

  def self.query_to_clause(query)
    pg_where(query.attrs).
      joins(query.joins).
      order(:year => :desc,
            :term => :asc,
            :department_id => :asc).
      order(query.orders).
      order(:number => :asc).
      includes([:course_sections,
                :labs,
                :recitations,
                :lab_lectures,
                :workshops,
                :department]).
      limit(query.limit || 150)
  end

  def self.sk_query(search_string)
    query = text_to_query(search_string)
    raise QueryingException, query.error if query.error
    
    if query.new
      query.attrs[:year] = 2016
      query.attrs[:term] = Term::Fall
    end

    clause = Course.query_to_clause(query)

    if query.new
      query.attrs[:year] = 2015
      last = Course.query_to_clause(query)

      clause = clause.where.not(number: last.collect(&:number) )
    end

    if (query.orders == ["RANDOM()"])
      clause = clause.reorder(query.orders)
    end
    
    clause
  end

  def all_offerings
    Course.where(number: number, department_id: department_id, title: title)
  end

  def requires_code?
    in_restrictions = restrictions && 
                      (restrictions["[A]"] || restrictions =~ /Permission of instructor required|Instructor's permission required/i)
    in_prereqs = prereqs &&
                 prereqs =~ /Permission of instructor required|Instructor's permission required/i
    !!(in_restrictions || in_prereqs)
  end
end

# == Schema Information
#
# Table name: courses
#
#  id            :integer          not null, primary key
#  title         :string(255)
#  number        :string(255)
#  description   :text
#  restrictions  :text
#  prereqs       :text
#  crosslisted   :text
#  comments      :text
#  credits       :integer
#  term          :integer
#  year          :integer
#  yr_term       :integer
#  min_enroll    :integer
#  min_start     :integer
#  max_start     :integer
#  department_id :integer
#
